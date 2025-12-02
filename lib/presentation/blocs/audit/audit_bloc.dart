import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/audit_log_model.dart';
import '../../../data/repositories/audit_repository.dart';

part 'audit_event.dart';
part 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository _repository;

  AuditBloc(this._repository) : super(AuditInitial()) {
    on<FetchAuditLogs>(_onFetchAuditLogs);
  }

  Future<void> _onFetchAuditLogs(
    FetchAuditLogs event,
    Emitter<AuditState> emit,
  ) async {
    emit(AuditLoading());
    try {
      final logs = await _repository.getAuditLogs();
      emit(AuditLoaded(logs));
    } catch (e) {
      emit(AuditError(e.toString()));
    }
  }
}
