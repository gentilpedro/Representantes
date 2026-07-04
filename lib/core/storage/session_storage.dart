import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazena o token JWT retornado pela Web API (.NET 10) de forma segura
/// no dispositivo, para reautenticação automática e para o [ApiClient]
/// anexar o header `Authorization`.
class SessionStorage {
  SessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _representativeCodeKey = 'representative_code';
  static const _userProfileKey = 'user_profile';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveRepresentativeCode(String code) =>
      _storage.write(key: _representativeCodeKey, value: code);

  Future<String?> readRepresentativeCode() =>
      _storage.read(key: _representativeCodeKey);

  /// Cacheia o perfil retornado pelo login, já que a Web API ainda não
  /// expõe um endpoint `/me` para recuperá-lo ao restaurar a sessão.
  Future<void> saveUserProfile(Map<String, dynamic> json) =>
      _storage.write(key: _userProfileKey, value: jsonEncode(json));

  Future<Map<String, dynamic>?> readUserProfile() async {
    final raw = await _storage.read(key: _userProfileKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear() => _storage.deleteAll();
}
