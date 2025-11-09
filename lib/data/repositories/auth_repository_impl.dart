import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/data/models/user_model.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';
import 'package:greengrow_app/core/config/api_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/login',
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );
      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Login gagal: response tidak valid dari server');
      }

      // 2. Cek status
      if (data['status'] == 'success') {
        final innerData = data['data'];
        if (innerData == null || innerData is! Map<String, dynamic>) {
          throw Exception('Login gagal: payload data tidak valid');
        }

        // 3. Ambil 'idToken' (BUKAN 'token')
        final token = innerData['idToken'];
        if (token == null || token is! String) {
          throw Exception('Login gagal: idToken tidak ditemukan dari server');
        }

        // 4. Simpan token ke secure storage
        await _secureStorage.write(key: 'auth_token', value: token);

        // 5. PANGGIL API KEDUA UNTUK MENDAPATKAN DATA USER
        // Kita panggil fungsi getUserProfile yang sudah Anda buat
        final UserModel user = await this.getUserProfile(token: token);

        // 6. Kembalikan token dan data user ke BLoC
        return {
          'message': data['message'] ?? 'Login successful',
          'token': token,
          'user': user, // Objek UserModel dari getUserProfile
        };
      } else {
        // Jika status BUKAN 'success'
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    String? phoneNumber,
    required int roleId,
    String? profilePhoto,
  }) async {
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'full_name': fullName,
        'phone_number': phoneNumber ?? '',
        'role_id': roleId,
        'profile_photo': profilePhoto,
      };
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/register',
        data: requestData,
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Register gagal: response tidak valid dari server');
      }

      if (data['status'] == 'success') {
        // Asumsi: respons register mengembalikan data user di 'data'
        return {
          'message': data['message'],
          'user': UserModel.fromJson(data['data']),
        };
      } else {
        throw Exception(data['message'] ?? 'Register gagal');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
        },
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Social login gagal: response tidak valid');
      }

      // Asumsi: social-login mengembalikan token & user di root
      final authToken = data['token'];
      final userJson = data['user'];

      if (authToken == null || userJson == null) {
        throw Exception('Social login gagal: token atau user tidak ada');
      }

      await _secureStorage.write(key: 'auth_token', value: authToken);

      return {
        'message': data['message'],
        'token': authToken,
        'user': UserModel.fromJson(userJson),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        await _dio.post(
          '${ApiConfig.baseUrl}/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      await _secureStorage.delete(key: 'auth_token');
    } on DioException catch (e) {
      // Seringkali, kita tidak ingin melempar error saat logout
      // Cukup hapus token lokal saja
      print('Error saat logout: $e');
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      print('Error saat logout: $e');
      await _secureStorage.delete(key: 'auth_token');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/auth/activity-logs',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      if (data == null ||
          data is! Map<String, dynamic> ||
          data['logs'] == null) {
        throw Exception('Gagal memuat log: data tidak valid');
      }

      return List<Map<String, dynamic>>.from(data['logs']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getUserProfile({required String token}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      print('User profile response: ' + data.toString());

      if (data == null || data is! Map<String, dynamic>) {
        throw Exception(
            'Failed to get user profile: response tidak valid dari server');
      }

      if (data['status'] == 'success') {
        // Asumsi: profil user ada di 'data'
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data;

      // Menangani error validasi dari backend (jika ada)
      if (data['errors'] != null && data['errors'] is List) {
        final errors = data['errors'] as List;
        final messages = errors.map((e) => e['msg'] ?? e.toString()).join('\n');
        return Exception(messages);
      }

      final message = data['message'] ?? data['error'] ?? data.toString();
      return Exception(message);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Koneksi timeout, silakan coba lagi.');
    }

    if (error.type == DioExceptionType.unknown) {
      return Exception('Koneksi internet bermasalah.');
    }

    return Exception('Terjadi kesalahan: ${error.message}');
  }
}
