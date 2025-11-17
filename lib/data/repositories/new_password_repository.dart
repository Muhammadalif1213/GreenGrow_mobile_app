import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';

class NewPasswordRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  NewPasswordRepository(this._dio, this._secureStorage);

  Future<void> resetPassword({required String newPassword}) async {
    final token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    final requestBody = {
      'newPassword': newPassword,
    };

    const url = '${ApiConfig.baseUrl}/profile/change-password';

    try {
      final response = await _dio.post(url,
          data: requestBody,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          }));
      if (response.data['status'] != 'success') {
        throw Exception(response.data['message'] ?? 'Gagal mengubah password');
      }
    } on DioException catch (e) {
      throw Exception(
          'Gagal mengubah password: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Gagal mengubah password.');
    }
  }
}
