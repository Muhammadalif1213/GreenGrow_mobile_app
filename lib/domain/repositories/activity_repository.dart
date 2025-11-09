import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/activity_log.dart';
import '../../core/config/api_config.dart';

class ActivityRepository {
  final String baseUrl = ApiConfig.baseUrl;
  final Dio _dio = Dio();

  Future<ActivityLog> createActivity({
    required int greenhouseId,
    required String activityType,
    required String description,
    required File photo,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/activities'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['greenhouse_id'] = greenhouseId.toString();
      request.fields['activity_type'] = activityType;
      request.fields['description'] = description;

      // Add photo file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ActivityLog.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to create activity: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating activity: $e');
    }
  }

  Future<List<ActivityLog>> getActivitiesByGreenhouse({
    required int greenhouseId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities/greenhouse/$greenhouseId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((json) => ActivityLog.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load activities: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading activities: $e');
    }
  }

  Future<List<ActivityLog>> getActivityLogsByGreenhouse(
    int greenhouseId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '$baseUrl/activities/greenhouse/$greenhouseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ActivityLog.fromJson(json)).toList();
      }
      throw Exception('Failed to load activities');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> createActivityLog({
    required int greenhouseId,
    required String activityType,
    required String description,
    required XFile photo,
    required String token,
  }) async {
    try {
      final formData = FormData.fromMap({
        'greenhouse_id': greenhouseId,
        'activity_type': activityType,
        'description': description,
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.name,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/activities',
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