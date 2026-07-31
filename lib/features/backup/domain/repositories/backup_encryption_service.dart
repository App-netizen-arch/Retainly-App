import 'dart:typed_data';

abstract class BackupEncryptionService {
  Future<Uint8List> encryptData(Uint8List data);
  Future<Uint8List> decryptData(Uint8List encryptedData);
  Future<bool> isEncryptionAvailable();
  Future<void> initialize();
}
