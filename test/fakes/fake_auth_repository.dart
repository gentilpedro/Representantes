import 'package:josapar_representantes/features/auth/domain/auth_exception.dart';
import 'package:josapar_representantes/features/auth/domain/entities/app_user.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';

/// Dobra de teste do [AuthRepository] — sessão em memória, sem rede.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _session = initialUser;

  factory FakeAuthRepository.loggedIn() =>
      FakeAuthRepository(initialUser: defaultUser);

  factory FakeAuthRepository.loggedOut() => FakeAuthRepository();

  static final defaultUser = AppUser(
    id: '88294',
    name: 'Ricardo Santos',
    role: 'Representante Comercial Sênior',
    region: 'Região Sul',
    appVersion: 'v2.4.0',
    lastSyncAt: DateTime(2026, 7, 2, 8, 30),
  );

  AppUser? _session;

  @override
  Future<AppUser?> restoreSession() async => _session;

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('Informe seu código ou e-mail e a senha.');
    }
    _session = defaultUser;
    return defaultUser;
  }

  @override
  Future<void> logout() async {
    _session = null;
  }

  @override
  Future<String> checkFirstAccess(String identifier) async => 'Novo Representante';

  @override
  Future<AppUser> activateAccount({
    required String identifier,
    required String password,
  }) async {
    _session = defaultUser;
    return defaultUser;
  }
}
