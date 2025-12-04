import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
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
}
