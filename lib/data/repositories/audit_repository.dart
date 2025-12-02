import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../models/audit_log_model.dart';

class AuditRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;

  AuditRepository(this.dio, [this.storage]);

  Future<List<AuditLogModel>> getAuditLogs() async {
    final token = await storage?.read(key: 'auth_token');
    if (token == null) throw Exception('Token tidak ditemukan');

    // Endpoint sesuai permintaan Anda
    final url = '${ApiConfig.baseUrl}/logs/audit-logs';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AuditLogModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil log');
      }
    } on DioException catch (e) {
      throw Exception('Gagal memuat log: ${e.message}');
    } catch (e) {
      throw Exception('Error parsing log: $e');
    }
  }
}