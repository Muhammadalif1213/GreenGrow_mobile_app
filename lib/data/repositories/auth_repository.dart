import 'package:greengrow_app/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    String? phoneNumber,
    required int roleId,
    String? profilePhoto,
  });

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  });

  Future<void> logout();

  Future<List<Map<String, dynamic>>> getActivityLogs();
  
  Future<UserModel> getUserProfile({required String token});
} 