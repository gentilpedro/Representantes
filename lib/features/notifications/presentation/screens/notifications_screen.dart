import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(filteredNotificationsProvider);
    final filter = ref.watch(notificationFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .markAllAsRead(),
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como lidas',
          ),
        ],
      ),
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      value: NotificationFilter.all,
                      groupValue: filter,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Não Lidas',
                      value: NotificationFilter.unread,
                      groupValue: filter,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pedidos',
                      value: NotificationFilter.orders,
                      groupValue: filter,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Promoções',
                      value: NotificationFilter.promotions,
                      groupValue: filter,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Não foi possível carregar as notificações.\n$error',
                  ),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma notificação encontrada.'),
                    );
                  }

                  final recent = notifications
                      .where((n) => n.isRecent)
                      .toList();
                  final older = notifications
                      .where((n) => !n.isRecent)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      if (recent.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'RECENTES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutralSoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${recent.length} Itens',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final n in recent) ...[
                          NotificationTile(
                            notification: n,
                            onTap: () => ref
                                .read(notificationsControllerProvider.notifier)
                                .markAsRead(n.id),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                      if (older.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'ANTERIORES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final n in older) ...[
                          NotificationTile(
                            notification: n,
                            onTap: () => ref
                                .read(notificationsControllerProvider.notifier)
                                .markAsRead(n.id),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends ConsumerWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
  });

  final String label;
  final NotificationFilter value;
  final NotificationFilter groupValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          ref.read(notificationFilterProvider.notifier).state = value,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
