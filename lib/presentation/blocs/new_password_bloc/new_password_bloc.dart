import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:greengrow_app/data/repositories/new_password_repository.dart';

part 'new_password_event.dart';
part 'new_password_state.dart';

class NewPasswordBloc extends Bloc<NewPasswordEvent, NewPasswordState> {
  final NewPasswordRepository newPasswordRepository;

  NewPasswordBloc({required this.newPasswordRepository}) : super(NewPasswordInitial()) {
    on<NewpassRequested>(_onNewpassRequested);

  }

  Future<void> _onNewpassRequested(
    NewpassRequested event,
    Emitter<NewPasswordState> emit,
  ) async {
    emit(NewPasswordLoading());

    if (event.newPassword.length >= 6) {
        emit(const NewPasswordSuccess('Kata sandi berhasil diubah.'));
      }
      if (event.newPassword.length < 6) {
        emit(const NewPasswordFailure('Kata sandi harus terdiri dari minimal 6 karakter.'));
      }

    try {
      // Simulasi permintaan pengaturan ulang kata sandi
      await Future.delayed(const Duration(seconds: 2));

      await newPasswordRepository.resetPassword(newPassword: event.newPassword);

    } catch (e) {
      emit(NewPasswordFailure(e.toString()));
    }
  }
}
