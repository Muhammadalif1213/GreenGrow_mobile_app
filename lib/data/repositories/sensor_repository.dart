import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../models/sensor_data_model.dart';

class SensorRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;

  SensorRepository(this.dio, [this.storage]);

  /// Mengambil data sensor TUNGGAL terbaru dari API.
  Future<SensorDataModel> getLatestSensorData() async {
    // 1. Ambil token dari storage
    final token = await storage?.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    final url = '${ApiConfig.baseUrl}/iot/status';

    try {
      // ===== INI LOG YANG ANDA INGINKAN =====
      print('== 1. MEMANGGIL SENSOR API ==');
      print('URL yang dipanggil: $url');
      // ===================================

      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // ===== INI LOG YANG ANDA INGINKAN =====
      print('== 2. DATA SENSOR DITERIMA (MENTAH) ==');
      print(response.data);
      // ===================================

      // 2. Parsing data
      return SensorDataModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('== GAGAL MENGAMBIL DATA SENSOR (DioException) ==');
      print('Error: ${e.message}');
      throw Exception('Gagal memuat data sensor: ${e.message}');
    } catch (e) {
      print('== GAGAL PARSING DATA SENSOR (Error) ==');
      print('Error: $e');
      throw Exception('Gagal mem-parsing data sensor.');
    }
  }
}
