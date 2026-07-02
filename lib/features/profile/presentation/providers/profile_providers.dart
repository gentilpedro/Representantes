import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/permission_item.dart';

/// Preferência local de UI — a implementação real persistiria isso (ex:
/// `shared_preferences`) e aplicaria via [ThemeMode] no `MaterialApp`.
final darkModeProvider = StateProvider<bool>((ref) => false);

/// Permissões do representante: hoje um espelho estático do protótipo — a
/// implementação real viria da Web API .NET 10 junto com o perfil do
/// usuário autenticado.
final permissionsProvider = Provider<List<PermissionItem>>((ref) {
  return const [
    PermissionItem(
      icon: Icons.check_circle,
      title: 'Vendas Offline Habilitadas',
      description: 'Você pode registrar pedidos sem conexão ativa.',
      status: PermissionStatus.granted,
    ),
    PermissionItem(
      icon: Icons.check_circle,
      title: 'Acesso a Tabelas Especiais',
      description: 'Autorizado para preços promocionais de atacado.',
      status: PermissionStatus.granted,
    ),
    PermissionItem(
      icon: Icons.lock,
      title: 'Aprovação de Crédito',
      description: 'Requer revisão da diretoria para limites acima de R\$ 50k.',
      status: PermissionStatus.restricted,
    ),
  ];
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
