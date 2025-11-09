import 'package:equatable/equatable.dart';

abstract class DeviceControlEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceControlRequested extends DeviceControlEvent {
  final String deviceType;
  final String action;

  DeviceControlRequested({required this.deviceType, required this.action});

  @override
  List<Object?> get props => [deviceType, action];
}

class DeviceControlFetchStatus extends DeviceControlEvent {}
