import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/notifications_exception.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Implementação real de [NotificationsRepository], contra
/// `GET /api/notifications` da Web API .NET 10.
class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._apiClient, this._db);

  static const _cacheKey = 'notifications';

  final ApiClient _apiClient;
  final AppDatabase _db;

  @override
  Future<List<AppNotification>> fetchAll() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/notifications',
      );
      await _db.upsertJsonCache(_cacheKey, jsonEncode(response.data));
      return response.data!
          .map((v) => _parseNotification(v as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      final cached = await _db.fetchJsonCache(_cacheKey);
      if (cached != null) {
        return (jsonDecode(cached) as List<dynamic>)
            .map((v) => _parseNotification(v as Map<String, dynamic>))
            .toList();
      }
      throw NotificationsException(
        'Não foi possível carregar as notificações. Tente novamente.',
      );
    }
  }

  AppNotification _parseNotification(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      category: NotificationCategory.values.byName(json['category'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      timeLabel: json['timeLabel'] as String,
      isUrgent: json['isUrgent'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      isRecent: json['isRecent'] as bool? ?? true,
    );
  }
}
