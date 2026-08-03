import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retainly/features/backup/data/repositories/backup_encryption_service.dart';

class _FakeSecureStorage implements SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('LocalBackupEncryptionService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initialize does not throw and sets up encryption key', () async {
      final service = LocalBackupEncryptionService(
        secureStorage: _FakeSecureStorage(),
        platformCheckOverride: () => true,
      );
      await service.initialize();
      expect(await service.isEncryptionAvailable(), isTrue);
    });

    test('encryptData and decryptData round-trip preserves data', () async {
      final service = LocalBackupEncryptionService(
        secureStorage: _FakeSecureStorage(),
        platformCheckOverride: () => true,
      );
      await service.initialize();
      final original = Uint8List.fromList(utf8.encode('test backup data'));
      final encrypted = await service.encryptData(original);
      expect(encrypted, isNot(original));
      expect(encrypted.length, greaterThan(original.length));
      final decrypted = await service.decryptData(encrypted);
      expect(decrypted, equals(original));
    });

    test('encryptData includes magic header', () async {
      final service = LocalBackupEncryptionService(
        secureStorage: _FakeSecureStorage(),
        platformCheckOverride: () => true,
      );
      await service.initialize();
      final original = Uint8List.fromList(utf8.encode('payload'));
      final encrypted = await service.encryptData(original);
      final header = utf8.decode(encrypted.sublist(0, 13));
      expect(header, 'MSP_BACKUP_V1');
    });

    test('decryptData throws FormatException for truncated data', () async {
      final service = LocalBackupEncryptionService(
        secureStorage: _FakeSecureStorage(),
        platformCheckOverride: () => true,
      );
      await service.initialize();
      final truncated = Uint8List.fromList(utf8.encode('MSP_BACKUP_V1'));
      expect(
        () => service.decryptData(truncated),
        throwsA(isA<FormatException>()),
      );
    });

    test('decryptData throws FormatException for empty data', () async {
      final service = LocalBackupEncryptionService(
        secureStorage: _FakeSecureStorage(),
        platformCheckOverride: () => true,
      );
      await service.initialize();
      expect(
        () => service.decryptData(Uint8List(0)),
        throwsA(isA<FormatException>()),
      );
    });

    test('key persists across instances via SecureStorage', () async {
      final sharedStorage = _FakeSecureStorage();
      final service1 = LocalBackupEncryptionService(
        secureStorage: sharedStorage,
        platformCheckOverride: () => true,
      );
      await service1.initialize();
      final original = Uint8List.fromList(utf8.encode('persistent test'));
      final encrypted = await service1.encryptData(original);

      final service2 = LocalBackupEncryptionService(
        secureStorage: sharedStorage,
        platformCheckOverride: () => true,
      );
      await service2.initialize();
      final decrypted = await service2.decryptData(encrypted);
      expect(decrypted, equals(original));
    });
  });
}
