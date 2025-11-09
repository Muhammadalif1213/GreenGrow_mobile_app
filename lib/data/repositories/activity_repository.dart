import 'package:dio/dio.dart';
import '../models/activity_log_model.dart';
import 'package:image_picker/image_picker.dart';

class ActivityRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api'));

  Future<List<ActivityLog>> getActivityLogs({required String token, required int greenhouseId}) async {
    final response = await _dio.get(
      '/activities',
      queryParameters: {'greenhouse_id': greenhouseId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data['data'] as List;
    return data.map((e) => ActivityLog.fromJson(e)).toList();
  }

  Future<void> uploadActivity({
    required String token,
    required String activityType,
    required String description,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      'activity_type': activityType,
      'description': description,
      if (photoPath != null)
        'photo': await MultipartFile.fromFile(photoPath, filename: photoPath.split('/').last),
    });

    await _dio.post(
      '/activity-log',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> createActivityLog({
    required int greenhouseId,
    required String activityType,
    required String description,
    required XFile photo,
    required String token,
    required String activityDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'greenhouse_id': greenhouseId,
        'activity_type': activityType,
        'description': description,
        'activity_date': activityDate,
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.name,
        ),
      });

      final response = await _dio.post(
        '/activities',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 