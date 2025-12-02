part of 'audit_bloc.dart';

sealed class AuditEvent extends Equatable {
  const AuditEvent();

  @override
  List<Object> get props => [];
}

class FetchAuditLogs extends AuditEvent {}