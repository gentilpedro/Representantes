import '../entities/app_user.dart';

/// Contrato de autenticação contra a Web API .NET 10 (`/api/auth/*`).
abstract class AuthRepository {
  Future<AppUser> login({required String identifier, required String password});

  Future<void> logout();

  Future<AppUser?> restoreSession();

  /// `POST /api/auth/first-access/check` — confirma que a matrícula existe e
  /// ainda não foi ativada, devolvendo o nome do representante para exibição.
  Future<String> checkFirstAccess(String identifier);

  /// `POST /api/auth/first-access/activate` — define a senha inicial e
  /// devolve a sessão já autenticada, como um login.
  Future<AppUser> activateAccount({
    required String identifier,
    required String password,
  });
}
