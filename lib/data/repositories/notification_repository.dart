import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../../domain/models/notification_model.dart';

class NotificationRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;
  // static const String _baseUrl = 'http://10.0.2.2:3000/api';

  NotificationRepository(this.dio, [this.storage]);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.get(
        '${ApiConfig.baseUrl}/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
          'unread_only': unreadOnly.toString(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          final List<dynamic> notificationsJson = data['notifications'];
          final List<NotificationModel> notifications = notificationsJson
              .map((item) => NotificationModel.fromJson(item))
              .toList();
          
          return {
            'notifications': notifications,
            'total': data['total'],
            'page': data['page'],
            'limit': data['limit'],
            'totalPages': data['total_pages'],
          };
        } else {
          throw Exception('Failed to load notifications: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.get(
        '${ApiConfig.baseUrl}/notifications/unread-count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          return responseData['data']['count'];
        } else {
          throw Exception('Failed to get unread count: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting unread count: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.put(
        '${ApiConfig.baseUrl}/notifications/$notificationId/read',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.put(
        '${ApiConfig.baseUrl}/notifications/read-all',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.delete(
        '${ApiConfig.baseUrl}/notifications/$notificationId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}