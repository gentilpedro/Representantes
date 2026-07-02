enum NotificationCategory { order, promotion, announcement, launch }

enum NotificationFilter { all, unread, orders, promotions }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.isUrgent = false,
    this.isRead = false,
    this.isRecent = true,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final String timeLabel;
  final bool isUrgent;
  final bool isRead;
  final bool isRecent;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      category: category,
      title: title,
      message: message,
      timeLabel: timeLabel,
      isUrgent: isUrgent,
      isRead: isRead ?? this.isRead,
      isRecent: isRecent,
    );
  }
}
