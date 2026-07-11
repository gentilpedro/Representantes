import 'package:josapar_representantes/features/profile/presentation/providers/profile_providers.dart';

/// Fica só em memória — evita bater no `path_provider` real (sem canal de
/// plataforma mockado no `flutter_test`, igual ao `AppDatabase`/Drift).
class FakeProfilePhotoController extends ProfilePhotoController {
  @override
  Future<void> setPhoto(String sourcePath) async {
    state = sourcePath;
  }

  @override
  Future<void> clear() async {
    state = null;
  }
}
