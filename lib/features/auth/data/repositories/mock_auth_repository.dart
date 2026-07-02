import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação mock: aceita qualquer credencial não vazia e devolve o
/// representante fixo visto no protótipo ("Ricardo Santos"). Simula a
/// latência de uma chamada real e persiste um token fake para manter a
/// sessão entre execuções, exatamente como a implementação real (contra a
/// Web API .NET 10) fará com um JWT de verdade.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._sessionStorage);

  final SessionStorage _sessionStorage;

  static final _fakeUser = AppUser(
    id: '88294',
    name: 'Ricardo Santos',
    role: 'Representante Comercial Sênior',
    region: 'Região Sul',
    appVersion: 'v2.4.0',
    lastSyncAt: DateTime.now(),
  );

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('Informe seu código ou e-mail e a senha.');
    }

    await _sessionStorage.saveToken('mock-jwt-token');
    await _sessionStorage.saveRepresentativeCode(_fakeUser.id);
    return _fakeUser;
  }

  @override
  Future<void> logout() => _sessionStorage.clear();

  @override
  Future<AppUser?> restoreSession() async {
    final token = await _sessionStorage.readToken();
    if (token == null) return null;
    return _fakeUser;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
