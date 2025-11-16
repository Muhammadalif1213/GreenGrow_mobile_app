part of 'device_control_bloc.dart';


abstract class DeviceControlEvent {}

/// Event untuk mengambil status terbaru (Automation, Blower, MaxTemp)
class DeviceControlFetchStatus extends DeviceControlEvent {}

/// Event untuk mengirim perintah ON/OFF ke perangkat
class DeviceControlRequested extends DeviceControlEvent {
  final String deviceType; // cth: 'blower'
  final String action;     // cth: 'ON' atau 'OFF'

  DeviceControlRequested({
    required this.deviceType,
    required this.action,
  });
}

class DeviceControlAutomationToggled extends DeviceControlEvent {
  final bool isEnabled;
  DeviceControlAutomationToggled({required this.isEnabled});
}

class DeviceControlBlowerToggled extends DeviceControlEvent {
  final bool isEnabled;
  DeviceControlBlowerToggled({required this.isEnabled});
}