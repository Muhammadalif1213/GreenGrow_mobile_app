import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final String? phoneNumber;
  final int roleId;
  final String? profilePhoto;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    this.phoneNumber,
    required this.roleId,
    this.profilePhoto,
  });

  @override
  List<Object?> get props => [
        username,
        email,
        password,
        confirmPassword,
        fullName,
        phoneNumber,
        roleId,
        profilePhoto,
      ];
}

class SocialLoginRequested extends AuthEvent {
  final String provider;
  final String token;

  const SocialLoginRequested({
    required this.provider,
    required this.token,
  });

  @override
  List<Object?> get props => [provider, token];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {} 