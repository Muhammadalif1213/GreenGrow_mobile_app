import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../models/automation_threshold_model.dart';

class AutomationThresholdRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AutomationThresholdRepository(this.dio, this.storage);

  Future<List<AutomationThresholdModel>> getThresholds() async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '${ApiConfig.baseUrl}/iot/status',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final list = response.data['data'] as List?;
    if (list == null) return [];
    return list.map((e) => AutomationThresholdModel.fromJson(e)).toList();
  }

  Future<void> upsertThreshold({
    required String parameter,
    required String deviceType,
    double? maxValue,
  }) async {
    final token = await storage.read(key: 'auth_token');
    await dio.post(
      '${ApiConfig.baseUrl}/iot/status',
      data: {
        'max_value': maxValue,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> updateThresholdById({
    required int id,
    double? maxValue,
  }) async {
    final token = await storage.read(key: 'auth_token');
    await dio.put(
      '${ApiConfig.baseUrl}/sensors/thresholds/$id',
      data: {
        'max_value': maxValue,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
} 