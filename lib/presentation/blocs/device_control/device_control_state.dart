part of 'device_control_bloc.dart';

abstract class DeviceControlState {}

class DeviceControlInitial extends DeviceControlState {}

class DeviceControlLoading extends DeviceControlState {}

class DeviceControlError extends DeviceControlState {
  final String message;
  DeviceControlError(this.message);
}

/// State sukses, menampung semua data konfigurasi dan status perangkat
class DeviceControlStatus extends DeviceControlState {
  final bool blowerOn;
  final bool isAutomationEnabled;
  final int maxTemp; // <-- Data baru kita
  final String? message; // Untuk SnackBar
  final bool? success;   // Untuk SnackBar

  DeviceControlStatus({
    required this.blowerOn,
    required this.isAutomationEnabled,
    required this.maxTemp,
    this.message,
    this.success,
  });

  /// Fungsi copyWith untuk memudahkan update state saat kontrol manual
  DeviceControlStatus copyWith({
    bool? blowerOn,
    bool? isAutomationEnabled,
    int? maxTemp,
    String? message,
    bool? success,
  }) {
    return DeviceControlStatus(
      blowerOn: blowerOn ?? this.blowerOn,
      isAutomationEnabled:
          isAutomationEnabled ?? this.isAutomationEnabled,
      maxTemp: maxTemp ?? this.maxTemp,
      message: message, // Message tidak di-copy, hanya di-set saat ada
      success: success, // Success juga tidak di-copy
    );
  }
}