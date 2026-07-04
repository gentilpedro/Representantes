import 'package:josapar_representantes/features/notifications/domain/entities/app_notification.dart';
import 'package:josapar_representantes/features/notifications/domain/repositories/notifications_repository.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> fetchAll() async {
    return const [
      AppNotification(
        id: 'n1',
        category: NotificationCategory.order,
        title: 'Pedido Aprovado #8829',
        message: 'Seu pedido foi aprovado e está sendo processado.',
        timeLabel: '10 min atrás',
        isUrgent: true,
      ),
      AppNotification(
        id: 'n2',
        category: NotificationCategory.announcement,
        title: 'Atualização de Tabela de Preços',
        message: 'Novos preços entram em vigor a partir de segunda-feira.',
        timeLabel: 'Ontem',
        isRead: true,
        isRecent: false,
      ),
    ];
  }
}
