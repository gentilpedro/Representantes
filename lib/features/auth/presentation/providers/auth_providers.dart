import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(sessionStorageProvider),
  );
});

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() {
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(identifier: identifier, password: password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    // Evita que a foto de um representante "vaze" pro próximo login no
    // mesmo aparelho, já que ela não é vinculada à conta no servidor.
    await ref.read(profilePhotoProvider.notifier).clear();
    state = const AsyncData(null);
  }

  Future<void> activateAccount({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .activateAccount(identifier: identifier, password: password),
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);
