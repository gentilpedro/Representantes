import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_profile_repository.dart';
import '../../domain/entities/permission_item.dart';
import '../../domain/repositories/profile_repository.dart';

const _darkModePrefsKey = 'dark_mode_enabled';

/// Preferência local de "Modo Escuro", persistida via `shared_preferences` e
/// aplicada ao [ThemeMode] do `MaterialApp` em `main.dart`.
class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_darkModePrefsKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModePrefsKey, value);
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository(ref.watch(apiClientProvider));
});

/// Permissões do representante, vindas da Web API .NET 10 junto com o perfil
/// do usuário autenticado.
final permissionsProvider = FutureProvider<List<PermissionItem>>((ref) {
  return ref.watch(profileRepositoryProvider).fetchPermissions();
});

class AppInfo {
  const AppInfo({required this.buildLabel, required this.cacheSizeLabel});

  final String buildLabel;
  final String cacheSizeLabel;
}

final appInfoProvider = Provider<AppInfo>((ref) {
  return const AppInfo(
    buildLabel: 'Build 2024.11.02',
    cacheSizeLabel: '64.5 MB utilizados',
  );
});
