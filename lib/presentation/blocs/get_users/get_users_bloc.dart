import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_management_repository.dart';

part 'get_users_event.dart';
part 'get_users_state.dart';

class UserManagementBloc extends Bloc<GetUsersEvent, GetUsersState> {
  final UserManagementRepository _repository;

  UserManagementBloc(this._repository) : super(GetUsersInitial()) {
    on<FetchAllUsers>(_onFetchAllUsers);
  }

  Future<void> _onFetchAllUsers(
      FetchAllUsers event, Emitter<GetUsersState> emit) async {
    emit(GetUsersLoading());
    try {
      final users = await _repository.getAllUsers();
      emit(GetUsersLoaded(users));
    } catch (e) {
      emit(GetUsersError(e.toString()));
    }
  }
}
