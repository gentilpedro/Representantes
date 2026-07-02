import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/permission_item.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final darkMode = ref.watch(darkModeProvider);
    final permissions = ref.watch(permissionsProvider);
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil e Configurações'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              user?.role ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                _MiniTag(label: 'ID: #${user?.id ?? '-'}'),
                                _MiniTag(label: user?.region ?? ''),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sync,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Última Sincronização: Hoje, ${user?.lastSyncAt != null ? AppFormatters.timeOfDay(user!.lastSyncAt!) : '-'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        user?.appVersion ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PREFERÊNCIAS DO SISTEMA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: darkMode,
                    onChanged: (value) =>
                        ref.read(darkModeProvider.notifier).state = value,
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Modo Escuro',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: const Text(
                      'Alternar visual da interface',
                      style: TextStyle(fontSize: 11),
                    ),
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.language_outlined,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Idioma',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: const Text(
                      'Português (Brasil)',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_none,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Notificações',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: const Text(
                      'Alertas de pedidos e promoções',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: Card(
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.textSecondary,
                  ),
                  title: const Text(
                    'PERMISSÕES E SEGURANÇA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                  children: [
                    for (final permission in permissions)
                      _PermissionRow(permission: permission),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Alterar Senha de Acesso'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SOBRE O APLICATIVO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Versão do Sistema',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      appInfo.buildLabel,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      user?.appVersion ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.storage_outlined,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Limpar Cache Offline',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      appInfo.cacheSizeLabel,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache offline limpo.')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'JOSAPAR S.A. © 2024',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.permission});

  final PermissionItem permission;

  @override
  Widget build(BuildContext context) {
    final isGranted = permission.status == PermissionStatus.granted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            permission.icon,
            size: 18,
            color: isGranted ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  permission.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
