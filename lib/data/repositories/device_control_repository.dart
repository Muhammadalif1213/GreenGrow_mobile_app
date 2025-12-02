import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import 'package:greengrow_app/data/models/sensor_data_model.dart';

class DeviceControlRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;

  DeviceControlRepository(this.dio, [this.storage]);

  /// Mengambil status konfigurasi perangkat (Automation, Blower, MaxTemp)
  Future<ConfigModel> getDeviceStatus() async {
    // 1. Ambil token
    final token = await storage?.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    // 2. Tentukan URL (pastikan endpoint-nya benar)
    const url = '${ApiConfig.baseUrl}/iot/config';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // 3. Cek status dan ambil objek 'data'
      if (response.data['status'] == 'success') {
        // 4. Ubah JSON 'data' menjadi ConfigModel
        return ConfigModel.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal mengambil konfigurasi');
      }
    } on DioException catch (e) {
      ('Error fetching config: $e');
      throw Exception('Gagal memuat konfigurasi: ${e.message}');
    } catch (e) {
      ('Error parsing config: $e');
      throw Exception('Gagal mem-parsing konfigurasi.');
    }
  }

  /// Mengirim perintah ON/OFF ke perangkat (cth: Blower)
  Future<void> setDeviceStatus({
    required String device, // cth: 'blower'
    required String status, // cth: 'ON' atau 'OFF'
  }) async {
    final token = await storage?.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan.');
    }

    // Tentukan endpoint untuk mengubah status.
    // Berdasarkan UI lama Anda, path-nya adalah '/automation/device'
    // Ganti jika path API Anda berbeda.
    const url = '${ApiConfig.baseUrl}/automation/device';

    Map<String, dynamic> requestBody = {};

    // Siapkan body request berdasarkan tipe perangkat
    if (device == 'blower') {
      requestBody = {'blower_status': status};
    } else if (device == 'sprayer') {
      // Tambahkan ini jika Anda punya sprayer
      requestBody = {'sprayer_status': status};
    } else {
      throw Exception('Tipe perangkat tidak dikenal: $device');
    }

    try {
      final response = await dio.put(
        url,
        data: requestBody,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.data['status'] != 'success') {
        throw Exception(response.data['message'] ?? 'Gagal mengubah status');
      }

      // Jika berhasil, tidak perlu mengembalikan apa-apa (void)
      // BLoC akan memanggil 'getDeviceStatus' lagi untuk refresh
    } on DioException catch (e) {
      throw Exception('Gagal mengubah status perangkat: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mengubah status perangkat.');
    }
  }

  Future<void> setAutomationStatus({required bool newStatus}) async {
    final token = await storage?.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    // 1. GANTI URL ke endpoint automation yang baru
    final url = '${ApiConfig.baseUrl}/iot/automation';

    // 2. Siapkan request body sesuai API baru Anda
    final requestBody = {'status': newStatus};

    try {
      // 3. GANTI METHOD dari PUT menjadi POST
      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      // Cek respons dari API baru Anda
      if (response.data['status'] != 'success') {
        throw Exception(
            response.data['message'] ?? 'Gagal mengubah status automation');
      }

      // Berhasil. BLoC akan me-refresh datanya.
    } on DioException catch (e) {
      // Tangani error jika respons tidak 200 (misal: 404, 500)
      throw Exception(
          'Gagal mengubah status automation: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Gagal mengubah status automation.');
    }
  }

  Future<void> setBlowerStatus({required bool newStatus}) async {
    final token = await storage?.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    // 1. GANTI URL ke endpoint blower yang baru
    final url = '${ApiConfig.baseUrl}/iot/blower';

    // 2. Siapkan request body sesuai API baru Anda
    final requestBody = {'status': newStatus};

    try {
      // 3. GANTI METHOD dari PUT menjadi POST
      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      // Cek respons dari API baru Anda
      if (response.data['status'] != 'success') {
        throw Exception(
            response.data['message'] ?? 'Gagal mengubah status Blower');
      }

      // Berhasil. BLoC akan me-refresh datanya.
    } on DioException catch (e) {
      // Tangani error jika respons tidak 200 (misal: 404, 500)
      throw Exception(
          'Gagal mengubah status Blower: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Gagal mengubah status Blower.');
    }
  }

  /// MEMPERBARUI: /api/iot/config (PUT) - Asumsi
  /// MEMPERBARUI: /api/iot/config (PUT)
  Future<void> updateMaxTemp({required int temp}) async {
    final token = await storage?.read(key: 'auth_token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = '${ApiConfig.baseUrl}/iot/maxtemp';
    final requestBody = {'temp': temp};

    try {
      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      // Cek status sukses dengan aman
      final data = response.data;
      if (data is Map && data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Gagal memperbarui suhu maks');
      }
    } on DioException catch (e) {

      String errorMessage = e.message ?? 'Gagal melakukan request';
      final responseData = e.response?.data;

      // 1. Cek dulu apakah responseData adalah Map (Object)
      if (responseData is Map<String, dynamic>) {
        // Jika Map, kita bisa aman mengambil 'message'
        errorMessage = responseData['message'] ?? errorMessage;
      }
      // 2. Cek jika responseData adalah List (Array)
      else if (responseData is List) {
        errorMessage = 'Error server: ${responseData.join(", ")}';
      }
      // 3. Jika String biasa
      else if (responseData is String) {
        errorMessage = responseData;
      }

      // Print untuk debugging di console agar Anda tahu isi aslinya
      print('DEBUG ERROR DATA: $responseData');

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
