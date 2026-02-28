import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/models/user_model.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveSession({required String token, required UserModel user}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
