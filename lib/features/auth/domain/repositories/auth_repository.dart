import '../entities/app_user.dart';

/// Contrato de autenticação. A implementação mock atual (usada enquanto a
/// Web API .NET 10 não está disponível) deve ser substituída por uma
/// implementação que chama `POST /api/auth/login` via [ApiClient], mantendo
/// esta mesma interface — nenhuma tela precisa mudar.
abstract class AuthRepository {
  Future<AppUser> login({required String identifier, required String password});

  Future<void> logout();

  Future<AppUser?> restoreSession();
}
