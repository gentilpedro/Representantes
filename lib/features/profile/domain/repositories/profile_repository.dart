import '../entities/permission_item.dart';

/// Contrato de perfil. A implementação real deve consumir a Web API .NET 10
/// (ex: `GET /api/profile/permissions`) junto com o perfil do usuário
/// autenticado.
abstract class ProfileRepository {
  Future<List<PermissionItem>> fetchPermissions();
}
