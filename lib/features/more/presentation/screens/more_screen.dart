import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';

/// Menu "Mais": agrupa as telas que não cabem na barra inferior principal
/// (Perfil, Relatórios & Indicadores, Sincronização, Notificações).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(
        icon: Icons.person_outline,
        label: 'Perfil e Configurações',
        route: AppRoutes.profile,
      ),
      _MoreItem(
        icon: Icons.bar_chart_outlined,
        label: 'Relatórios & Indicadores',
        route: AppRoutes.reports,
      ),
      _MoreItem(
        icon: Icons.sync_outlined,
        label: 'Sincronização',
        route: AppRoutes.sync,
      ),
      _MoreItem(
        icon: Icons.notifications_outlined,
        label: 'Notificações',
        route: AppRoutes.notifications,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ResponsiveContent(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(item.route),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
