import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _partnerIdKey = 'partner_id'; // Ключ для хранения ID партнера

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> savePartnerId(String partnerId) async {
    await _storage.write(key: _partnerIdKey, value: partnerId);
  }

  Future<String?> getPartnerId() async {
    return await _storage.read(key: _partnerIdKey);
  }

  Future<void> deletePartnerId() async {
    await _storage.delete(key: _partnerIdKey);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll(); // Удаляет все сохраненные данные
  }
}