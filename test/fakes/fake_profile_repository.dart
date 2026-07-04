import 'package:flutter/material.dart';
import 'package:josapar_representantes/features/profile/domain/entities/permission_item.dart';
import 'package:josapar_representantes/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<List<PermissionItem>> fetchPermissions() async {
    return const [
      PermissionItem(
        icon: Icons.check_circle_outline,
        title: 'Vendas Offline',
        description: 'Registrar pedidos sem conexão com a internet.',
        status: PermissionStatus.granted,
      ),
      PermissionItem(
        icon: Icons.table_chart_outlined,
        title: 'Acesso a Tabelas Especiais',
        description: 'Ver preços e condições comerciais diferenciadas.',
        status: PermissionStatus.granted,
      ),
      PermissionItem(
        icon: Icons.lock_outline,
        title: 'Aprovação de Crédito',
        description: 'Aprovar pedidos acima do limite de crédito padrão.',
        status: PermissionStatus.granted,
      ),
    ];
  }
}
