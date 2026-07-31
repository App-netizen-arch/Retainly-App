import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/backup_encryption_service.dart';

class LocalBackupEncryptionService implements BackupEncryptionService {
  static const _keyStorageKey = 'backup_encryption_key';
  static const _magicHeader = 'MSP_BACKUP_V1';
  static const _secureStorageKey = 'backup_encryption_key_secure';
  final FlutterSecureStorage _secureStorage;
  bool _useSecureStorage = true;
  Key? _key;

  LocalBackupEncryptionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> initialize() async {
    if (_key != null) return;
    String? storedKey;
    if (_useSecureStorage) {
      try {
        if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
          storedKey = await _secureStorage.read(key: _secureStorageKey);
        } else {
          _useSecureStorage = false;
        }
      } catch (_) {
        _useSecureStorage = false;
      }
    }
    if (_useSecureStorage && storedKey != null && storedKey.isNotEmpty) {
      final keyBytes = base64Decode(storedKey);
      _key = Key(keyBytes);
    } else {
      if (!_useSecureStorage) {
        try {
          final prefs = await SharedPreferences.getInstance();
          storedKey = prefs.getString(_keyStorageKey);
        } on Exception {
          storedKey = null;
        }
      }
      if (storedKey != null && storedKey.isNotEmpty) {
        final keyBytes = base64Decode(storedKey);
        _key = Key(keyBytes);
      } else {
        final newKey = Key.fromSecureRandom(32);
        if (_useSecureStorage) {
          try {
            await _secureStorage.write(
              key: _secureStorageKey,
              value: base64Encode(newKey.bytes),
            );
          } catch (_) {
            _useSecureStorage = false;
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                _keyStorageKey,
                base64Encode(newKey.bytes),
              );
            } catch (_) {
              // Key storage is best-effort; encryption still works with in-memory key
            }
          }
        } else {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_keyStorageKey, base64Encode(newKey.bytes));
          } catch (_) {
            // Key storage is best-effort; encryption still works with in-memory key
          }
        }
        _key = newKey;
      }
    }
  }

  @override
  Future<bool> isEncryptionAvailable() async {
    try {
      await initialize();
      return _key != null;
    } on Exception {
      return false;
    }
  }

  Key _getKey() {
    if (_key == null) {
      throw StateError('Encryption not initialized. Call initialize() first.');
    }
    return _key!;
  }

  @override
  Future<Uint8List> encryptData(Uint8List data) async {
    await initialize();
    final key = _getKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    final header = utf8.encode(_magicHeader);
    final result = <int>[...header, ...iv.bytes, ...encrypted.bytes];
    return Uint8List.fromList(result);
  }

  @override
  Future<Uint8List> decryptData(Uint8List encryptedData) async {
    await initialize();
    final key = _getKey();
    final headerBytes = utf8.encode(_magicHeader);
    if (encryptedData.length < headerBytes.length + 16) {
      throw const FormatException('Invalid encrypted backup format');
    }
    final dataStart = headerBytes.length;
    final iv = IV(encryptedData.sublist(dataStart, dataStart + 16));
    final cipherText = encryptedData.sublist(dataStart + 16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decryptBytes(Encrypted(cipherText), iv: iv);
    return Uint8List.fromList(decrypted);
  }
}
