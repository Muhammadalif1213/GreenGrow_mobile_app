import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';

class DeviceControlRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  // static const String _baseUrl = 'http://10.0.2.2:3000/api';

  DeviceControlRepository(this.dio, this.storage);

  Future<Map<String, dynamic>> fetchStatus() async {
    final token = await storage.read(key: 'auth_token');
    final res = await dio.get(
      '${ApiConfig.baseUrl}/sensors/automation/status',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> controlDevice({
    required String deviceType,
    required String action,
  }) async {
    final token = await storage.read(key: 'auth_token');
    String endpoint = deviceType == 'blower'
        ? '/sensors/device/blower'
        : '/sensors/device/sprayer';
    try {
      final res = await dio.put(
        '${ApiConfig.baseUrl}$endpoint',
        data: {'action': action},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data;
    } on DioError catch (e) {
      // Ambil pesan error dari backend jika ada
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
