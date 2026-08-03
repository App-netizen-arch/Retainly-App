import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/backup_encryption_service.dart';

abstract class SecureStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
}

class FlutterSecureStorageWrapper implements SecureStorage {
  final FlutterSecureStorage _delegate;
  FlutterSecureStorageWrapper(this._delegate);

  @override
  Future<String?> read({required String key}) => _delegate.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _delegate.write(key: key, value: value);
}

class LocalBackupEncryptionService implements BackupEncryptionService {
  static const _magicHeader = 'MSP_BACKUP_V1';
  static const _secureStorageKey = 'backup_encryption_key_secure';
  final SecureStorage _secureStorage;
  final bool Function()? _platformCheckOverride;
  Key? _key;

  LocalBackupEncryptionService({
    SecureStorage? secureStorage,
    bool Function()? platformCheckOverride,
  }) : _secureStorage = secureStorage ??
        FlutterSecureStorageWrapper(FlutterSecureStorage()),
     _platformCheckOverride = platformCheckOverride;

  bool get _isSupportedPlatform {
    final override = _platformCheckOverride;
    if (override != null) return override();
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @override
  Future<void> initialize() async {
    if (_key != null) return;
    String? storedKey;
    try {
      if (_isSupportedPlatform) {
        storedKey = await _secureStorage.read(key: _secureStorageKey);
      } else {
        throw Exception('Secure storage not available on this platform');
      }
    } catch (e) {
      throw Exception('Failed to read encryption key from secure storage: $e');
    }
    if (storedKey != null && storedKey.isNotEmpty) {
      final keyBytes = base64Decode(storedKey);
      _key = Key(keyBytes);
    } else {
      final newKey = Key.fromSecureRandom(32);
      try {
        await _secureStorage.write(
          key: _secureStorageKey,
          value: base64Encode(newKey.bytes),
        );
      } catch (e) {
        throw Exception('Failed to persist encryption key: $e');
      }
      _key = newKey;
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
