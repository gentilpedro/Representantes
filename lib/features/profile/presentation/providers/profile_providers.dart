import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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

/// Base pra permitir substituir por um fake nos testes — a implementação
/// real usa `path_provider`, sem canal de plataforma mockado no
/// `flutter_test` (mesma razão pela qual `AppDatabase`/Drift também nunca é
/// exercitado de verdade nos testes de fluxo, só com fakes de repositório).
abstract class ProfilePhotoController extends StateNotifier<String?> {
  ProfilePhotoController() : super(null);

  Future<void> setPhoto(String sourcePath);

  Future<void> clear();
}

/// Foto de perfil escolhida pelo representante (câmera ou galeria) — fica só
/// no aparelho, sem sincronizar com o servidor. Sempre salva com o mesmo
/// nome fixo dentro do diretório de documentos do app: dispensa persistir o
/// caminho em `shared_preferences` (o "carregar" é só checar se o arquivo
/// existe).
class ProfilePhotoNotifier extends ProfilePhotoController {
  ProfilePhotoNotifier() {
    _load();
  }

  Future<String> _photoFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/profile_photo.jpg';
  }

  Future<void> _load() async {
    final path = await _photoFilePath();
    if (await File(path).exists()) {
      state = path;
    }
  }

  @override
  Future<void> setPhoto(String sourcePath) async {
    final destPath = await _photoFilePath();
    await File(sourcePath).copy(destPath);
    state = destPath;
  }

  @override
  Future<void> clear() async {
    final path = await _photoFilePath();
    final file = File(path);
    if (await file.exists()) await file.delete();
    state = null;
  }
}

final profilePhotoProvider =
    StateNotifierProvider<ProfilePhotoController, String?>((ref) {
      return ProfilePhotoNotifier();
    });

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
  );
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
  final packageInfo = ref.watch(packageInfoProvider);
  return AppInfo(
    buildLabel: packageInfo.whenOrNull(data: formatAppVersion) ?? '...',
    cacheSizeLabel: '64.5 MB utilizados',
  );
});
