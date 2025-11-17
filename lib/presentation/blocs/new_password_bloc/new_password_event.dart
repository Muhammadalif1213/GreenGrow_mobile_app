part of 'new_password_bloc.dart';

sealed class NewPasswordEvent extends Equatable {
  const NewPasswordEvent();

  @override
  List<Object> get props => [];
}

class NewpassRequested extends NewPasswordEvent {
  final String newPassword;

  const NewpassRequested({
    required this.newPassword,
  });

  @override
  List<Object> get props => [newPassword];
}
