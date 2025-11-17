part of 'new_password_bloc.dart';

sealed class NewPasswordState extends Equatable {
  const NewPasswordState();
  
  @override
  List<Object> get props => [];
}

final class NewPasswordInitial extends NewPasswordState {}
final class NewPasswordLoading extends NewPasswordState {}

final class NewPasswordSuccess extends NewPasswordState {
  final String message;

  const NewPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class NewPasswordFailure extends NewPasswordState {
  final String error;

  const NewPasswordFailure(this.error);

  @override
  List<Object> get props => [error];
}