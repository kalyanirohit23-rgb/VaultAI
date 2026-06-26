import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for encrypting/decrypting sensitive data
class EncryptionService {
  static const _keyStorageKey = 'vault_ai_encryption_key';
  final _storage = const FlutterSecureStorage();

  Future<String> encrypt(String plainText) async {
    final key = await _getOrCreateKey();
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Store IV with the encrypted data
    final combined = '${base64Encode(iv.bytes)}:${encrypted.base64}';
    return combined;
  }

  Future<String> decrypt(String encryptedText) async {
    final key = await _getOrCreateKey();
    final encrypter = Encrypter(AES(key));
    final parts = encryptedText.split(':');
    if (parts.length != 2) throw const FormatException('Invalid encrypted format');
    final iv = IV(base64Decode(parts[0]));
    final encrypted = Encrypted.fromBase64(parts[1]);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<Key> _getOrCreateKey() async {
    final storedKey = await _storage.read(key: _keyStorageKey);
    if (storedKey != null) {
      return Key(base64Decode(storedKey));
    }
    final newKey = Key.fromSecureRandom(32);
    await _storage.write(key: _keyStorageKey, value: base64Encode(newKey.bytes));
    return newKey;
  }
}
