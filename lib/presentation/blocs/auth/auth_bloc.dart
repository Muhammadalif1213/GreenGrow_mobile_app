import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_event.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        // rememberMe: event.rememberMe,
      );
      emit(Authenticated(response['user'], response['token']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        roleId: event.roleId,
        profilePhoto: event.profilePhoto,
      );
      // Jika response tidak ada token, anggap register sukses tanpa login otomatis
      if (response['token'] == null) {
        emit(AuthSuccess(response['message'] ?? 'Register berhasil'));
      } else {
        emit(Authenticated(response['user'], response['token']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.socialLogin(
        provider: event.provider,
        token: event.token,
      );
      emit(Authenticated(response['user'], response['token']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Implement token validation logic here
      // For now, we'll just emit Unauthenticated
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
