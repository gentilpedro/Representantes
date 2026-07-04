import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_notifications_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => ApiNotificationsRepository(ref.watch(apiClientProvider)),
);

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationsRepositoryProvider).fetchAll();
  }

  void markAsRead(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final n in current)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
  }

  void markAllAsRead() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

final notificationFilterProvider =
    StateProvider.autoDispose<NotificationFilter>(
      (ref) => NotificationFilter.all,
    );

final filteredNotificationsProvider =
    Provider.autoDispose<AsyncValue<List<AppNotification>>>((ref) {
      final notificationsAsync = ref.watch(notificationsControllerProvider);
      final filter = ref.watch(notificationFilterProvider);

      return notificationsAsync.whenData((notifications) {
        return notifications.where((n) {
          return switch (filter) {
            NotificationFilter.all => true,
            NotificationFilter.unread => !n.isRead,
            NotificationFilter.orders =>
              n.category == NotificationCategory.order,
            NotificationFilter.promotions =>
              n.category == NotificationCategory.promotion,
          };
        }).toList();
      });
    });
