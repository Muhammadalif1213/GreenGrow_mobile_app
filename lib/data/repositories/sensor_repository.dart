import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import '../models/sensor_data_model.dart';
import '../models/sensor_log_model.dart';

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

  Future<SensorDataModel> setMaxThresholds({
    required double maxTemperature,
  }) async {
    final token = await storage?.read(key: 'auth_token');
    final role = await storage?.read(key: 'role');

    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    if (role != 'admin') {
      throw Exception('Hanya Admin yang dapat mengatur ambang batas sensor.');
    }

    final url = '${ApiConfig.baseUrl}/iot/config';

    try {
      print('== 1. MENGATUR AMBANG BATAS MAKSIMUM SENSOR ==');
      print('URL yang dipanggil: $url');

      final response = await dio.post(
        url,
        data: {
          'max_temperature': maxTemperature,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('== 2. DATA AMBANG BATAS DITERIMA (MENTAH) ==');
      print(response.data);

      return SensorDataModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('== GAGAL MENGATUR AMBANG BATAS SENSOR (DioException) ==');
      print('Error: ${e.message}');
      throw Exception('Gagal mengatur ambang batas sensor: ${e.message}');
    } catch (e) {
      print('== GAGAL PARSING DATA AMBANG BATAS SENSOR (Error) ==');
      print('Error: $e');
      throw Exception('Gagal mem-parsing data ambang batas sensor.');
    }
  }

  Future<List<SensorLogModel>> getSensorLogs() async {
    try {
      // Ambil token dari storage
      final token =
          await storage?.read(key: 'auth_token'); // Sesuaikan key token Anda

      final response = await dio.get(
        '${ApiConfig.baseUrl}/logs/sensor-logs', // Pastikan base URL benar
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Kirim Token Admin
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        // Mapping data JSON ke List<Model>
        // Kita reverse agar urutan tanggal dari kiri (lama) ke kanan (baru) di grafik
        return data
            .map((json) => SensorLogModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        throw Exception('Failed to load logs');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
