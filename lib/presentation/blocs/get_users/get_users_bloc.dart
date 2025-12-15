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
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<GetUsersState>
        emit, // Pastikan State sesuai (GetUsersState atau UserManagementState)
  ) async {
    // 1. Simpan state saat ini (yang berisi list user)
    final currentState = state;

    try {
      // 2. Panggil API Delete ke Server
      await _repository.deleteUser(event.uid);

      // 3. LOGIKA AUTO REFRESH (Optimistic Update)
      // Kita langsung manipulasi list di memori tanpa loading ulang dari server
      if (currentState is GetUsersLoaded) {
        // Buat list baru dengan membuang user yang UID-nya sama dengan event.uid
        final updatedList =
            currentState.users.where((user) => user.uid != event.uid).toList();

        // 4. Emit State Baru dengan List yang sudah bersih
        emit(GetUsersLoaded(updatedList));
      } else {
        // Fallback: Jika state tidak valid, fetch ulang dari server
        add(FetchAllUsers());
      }
    } catch (e) {
      // Jika gagal delete di server
      emit(GetUsersError("Gagal menghapus user: $e"));

      // Kembalikan list semula agar layar tidak kosong
      if (currentState is GetUsersLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onFetchAllUsers(
    FetchAllUsers event,
    Emitter<GetUsersState> emit,
  ) async {
    emit(GetUsersLoading());
    try {
      final users = await _repository.getAllUsers();

      // === FILTERING DI SINI ===
      // Hanya ambil user yang isDeleted-nya FALSE
      final activeUsers =
          users.where((user) => user.isDeleted == false).toList();

      emit(GetUsersLoaded(activeUsers));
    } catch (e) {
      emit(GetUsersError(e.toString()));
    }
  }
}
