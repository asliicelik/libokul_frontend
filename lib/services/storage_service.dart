// lib/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Tokenları saklamak için FlutterSecureStorage kullanıyoruz.
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'auth_token';

  // Token'ı güvenli bir şekilde kaydeder.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Saklanan Token'ı okur (Uygulama açıldığında veya API isteği gönderirken kullanılır).
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Token'ı siler (Kullanıcı çıkış yaptığında).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}