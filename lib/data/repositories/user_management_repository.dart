import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../models/system_log_model.dart';
import '../models/user_model.dart';

class UserManagementRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  UserManagementRepository(this.dio, this.storage);

  Future<List<UserModel>> getAllUsers() async {
    final token = await storage.read(key: 'auth_token');

    // Ganti endpoint sesuai API Anda, misal: /users
    final url = '${ApiConfig.baseUrl}/admin/users';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        // PERHATIKAN CARA PARSING LIST:
        final List<dynamic> dataList = response.data['data'];

        return dataList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal mengambil data user');
      }
    } on DioException catch (e) {
      throw Exception(
          'Gagal memuat users: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Error parsing users: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Token not found');

    // Menggunakan UID di dalam URL
    final url = '${ApiConfig.baseUrl}/admin/users/$uid';

    try {
      final response = await dio.delete(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Cek response status (biasanya 200 atau 204)
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus user');
      }

      // Jika json response memiliki status 'error'
      if (response.data is Map && response.data['status'] == 'error') {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          'Gagal menghapus user: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<SystemLog>> getSystemLogs() async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) throw Exception('Sesi habis, silakan login kembali.');

    // URL Log System
    // Asumsi ApiConfig.baseUrl kamu berakhiran '/api'
    // (sesuai pola /admin/users di atas)
    final url = '${ApiConfig.baseUrl}/logs/system-logs';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> dataList = response.data['data'];

        // Mapping JSON ke Model SystemLog
        return dataList.map((json) => SystemLog.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal mengambil system logs');
      }
    } on DioException catch (e) {
      // Handle jika 401 Unauthorized (Token expired)
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Silakan login ulang.');
      }
      throw Exception(
          'Gagal memuat logs: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Error parsing logs: $e');
    }
  }
}
