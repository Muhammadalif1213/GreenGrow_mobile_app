part of 'get_users_bloc.dart';

sealed class GetUsersState extends Equatable {
  const GetUsersState();

  @override
  List<Object> get props => [];
}

final class GetUsersInitial extends GetUsersState {}

class GetUsersLoading extends GetUsersState {}

class GetUsersLoaded extends GetUsersState {
  final List<UserModel> users;
  const GetUsersLoaded(this.users);
}

class GetUsersError extends GetUsersState {
  final String message;
  const GetUsersError(this.message);
}
