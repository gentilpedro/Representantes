import '../entities/app_notification.dart';

/// Contrato de notificações. A implementação real deve consumir a Web API
/// .NET 10 (ex: `GET /api/notifications`) e idealmente um canal push/SignalR
/// para tempo real.
abstract class NotificationsRepository {
  Future<List<AppNotification>> fetchAll();
}
