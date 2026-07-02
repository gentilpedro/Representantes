import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazena o token JWT retornado pela Web API (.NET 10) de forma segura
/// no dispositivo, para reautenticação automática e para o [ApiClient]
/// anexar o header `Authorization`.
class SessionStorage {
  SessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _representativeCodeKey = 'representative_code';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveRepresentativeCode(String code) =>
      _storage.write(key: _representativeCodeKey, value: code);

  Future<String?> readRepresentativeCode() =>
      _storage.read(key: _representativeCodeKey);

  Future<void> clear() => _storage.deleteAll();
}
