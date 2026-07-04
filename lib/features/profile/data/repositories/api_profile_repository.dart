import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/permission_item.dart';
import '../../domain/profile_exception.dart';
import '../../domain/repositories/profile_repository.dart';

/// Ícones conhecidos para permissões — o backend devolve um nome simples
/// (ex: "check_circle", "lock") que é mapeado para o [IconData]
/// correspondente. Nomes desconhecidos caem no ícone padrão.
const _iconsByName = <String, IconData>{
  'check_circle': Icons.check_circle,
  'lock': Icons.lock,
};

/// Implementação real de [ProfileRepository], contra
/// `GET /api/profile/permissions` da Web API .NET 10.
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PermissionItem>> fetchPermissions() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/profile/permissions',
      );
      return response.data!
          .map((v) => _parsePermission(v as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      throw ProfileException(
        'Não foi possível carregar as permissões. Tente novamente.',
      );
    }
  }

  PermissionItem _parsePermission(Map<String, dynamic> json) {
    return PermissionItem(
      icon: _iconsByName[json['icon'] as String?] ?? Icons.shield_outlined,
      title: json['title'] as String,
      description: json['description'] as String,
      status: PermissionStatus.values.byName(json['status'] as String),
    );
  }
}
