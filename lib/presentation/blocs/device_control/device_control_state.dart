import 'package:equatable/equatable.dart';

abstract class DeviceControlState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceControlInitial extends DeviceControlState {}

class DeviceControlLoading extends DeviceControlState {
  final String deviceType;
  DeviceControlLoading(this.deviceType);
  @override
  List<Object?> get props => [deviceType];
}

class DeviceControlStatus extends DeviceControlState {
  final bool blowerOn;
  final bool sprayerOn;
  final bool isAutomationEnabled;
  final String? lastChangedDevice; // 'blower' atau 'sprayer'
  final bool? lastChangedValue; // true=ON, false=OFF
  final String? message;
  final bool? success;
  DeviceControlStatus({
    required this.blowerOn,
    required this.sprayerOn,
    required this.isAutomationEnabled,
    this.lastChangedDevice,
    this.lastChangedValue,
    this.message,
    this.success,
  });
  @override
  List<Object?> get props => [
        blowerOn,
        sprayerOn,
        isAutomationEnabled,
        lastChangedDevice,
        lastChangedValue,
        message,
        success
      ];
}

class DeviceControlSuccess extends DeviceControlState {}

class DeviceControlError extends DeviceControlState {
  final String message;
  DeviceControlError(this.message);

  @override
  List<Object?> get props => [message];
}
