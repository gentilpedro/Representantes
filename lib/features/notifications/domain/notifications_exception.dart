class NotificationsException implements Exception {
  NotificationsException(this.message);
  final String message;

  @override
  String toString() => message;
}
