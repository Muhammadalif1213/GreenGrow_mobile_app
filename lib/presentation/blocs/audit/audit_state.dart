part of 'audit_bloc.dart';

sealed class AuditState extends Equatable {
  const AuditState();

  @override
  List<Object> get props => [];
}

final class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditLogModel> logs;
  const AuditLoaded(this.logs);
}

class AuditError extends AuditState {
  final String message;
  const AuditError(this.message);
}
