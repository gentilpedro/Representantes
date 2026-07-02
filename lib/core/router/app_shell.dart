import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/sync/presentation/providers/sync_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_content.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Início',
    ),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Clientes'),
    (
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Pedidos',
    ),
    (
      icon: Icons.event_available_outlined,
      activeIcon: Icons.event_available,
      label: 'Agenda',
    ),
    (icon: Icons.more_horiz, activeIcon: Icons.more_horiz, label: 'Mais'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantém o SyncController "vivo" assim que o usuário está logado, para
    // que o listener de conectividade dispare a sincronização automática
    // mesmo com a tela de Sincronização fechada.
    ref.watch(syncControllerProvider);

    if (AppBreakpoints.isDesktop(context)) {
      return _DesktopShell(navigationShell: navigationShell);
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          for (final d in _destinations)
            BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.activeIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final extended = AppBreakpoints.isWideDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 220,
            backgroundColor: AppColors.surface,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.textMuted,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textMuted,
            ),
            leading: Padding(
              padding: EdgeInsets.symmetric(vertical: extended ? 20 : 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    const Text(
                      'Josapar Rep.',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            destinations: [
              for (final d in AppShell._destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.border,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
