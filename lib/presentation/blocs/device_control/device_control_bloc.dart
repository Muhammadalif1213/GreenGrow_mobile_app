import 'package:flutter_bloc/flutter_bloc.dart';
import 'device_control_event.dart';
import 'device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';
import 'package:dio/dio.dart';

class DeviceControlBloc extends Bloc<DeviceControlEvent, DeviceControlState> {
  final DeviceControlRepository repository;

  DeviceControlBloc(this.repository)
      : super(DeviceControlStatus(
          blowerOn: false,
          sprayerOn: false,
          isAutomationEnabled: false,
        )) {
    on<DeviceControlFetchStatus>((event, emit) async {
      emit(DeviceControlLoading('all'));
      try {
        final res = await repository.fetchStatus();
        final data = res['data'] ?? {};
        emit(DeviceControlStatus(
          blowerOn:
              (data['blower_status'] ?? '').toString().toUpperCase() == 'ON',
          sprayerOn:
              (data['sprayer_status'] ?? '').toString().toUpperCase() == 'ON',
          isAutomationEnabled: data['is_automation_enabled'] ?? false,
        ));
      } catch (e) {
        emit(DeviceControlError('Gagal mengambil status perangkat: $e'));
      }
    });

    on<DeviceControlRequested>((event, emit) async {
      final currentState = state;
      bool blowerOn = false;
      bool sprayerOn = false;
      bool isAutomationEnabled = false;
      if (currentState is DeviceControlStatus) {
        blowerOn = currentState.blowerOn;
        sprayerOn = currentState.sprayerOn;
        isAutomationEnabled = currentState.isAutomationEnabled;
      }
      emit(DeviceControlLoading(event.deviceType));
      try {
        // Fetch status dulu
        final statusRes = await repository.fetchStatus();
        final statusData = statusRes['data'] ?? {};
        isAutomationEnabled = statusData['is_automation_enabled'] ?? false;
        blowerOn =
            (statusData['blower_status'] ?? '').toString().toUpperCase() ==
                'ON';
        sprayerOn =
            (statusData['sprayer_status'] ?? '').toString().toUpperCase() ==
                'ON';
        if (isAutomationEnabled) {
          emit(DeviceControlStatus(
            blowerOn: blowerOn,
            sprayerOn: sprayerOn,
            isAutomationEnabled: isAutomationEnabled,
            message:
                'Matikan mode automation untuk kontrol manual ${event.deviceType}.',
            success: false,
          ));
          return;
        }
        final res = await repository.controlDevice(
          deviceType: event.deviceType,
          action: event.action,
        );
        final msg = res['message'] ?? 'Berhasil mengubah status.';
        final success = res['success'] ?? false;
        // Tambahkan delay sebelum fetch status ulang
        await Future.delayed(const Duration(milliseconds: 500));
        // Fetch status lagi setelah kontrol
        final afterRes = await repository.fetchStatus();
        final afterData = afterRes['data'] ?? {};
        blowerOn =
            (afterData['blower_status'] ?? '').toString().toUpperCase() == 'ON';
        sprayerOn =
            (afterData['sprayer_status'] ?? '').toString().toUpperCase() ==
                'ON';
        isAutomationEnabled = afterData['is_automation_enabled'] ?? false;
        emit(DeviceControlStatus(
          blowerOn: blowerOn,
          sprayerOn: sprayerOn,
          isAutomationEnabled: isAutomationEnabled,
          lastChangedDevice: event.deviceType,
          lastChangedValue: event.action == 'ON',
          message: msg,
          success: success,
        ));
      } catch (e) {
        String errorMsg = 'Gagal mengubah status: ';
        if (e is DioError) {
          if (e.response != null && e.response?.data != null) {
            errorMsg +=
                e.response?.data['message'] ?? (e.message ?? 'Unknown error');
          } else {
            errorMsg += e.message ?? 'Unknown error';
          }
        } else {
          errorMsg += e.toString();
        }
        emit(DeviceControlError(errorMsg));
        emit(DeviceControlStatus(
          blowerOn: blowerOn,
          sprayerOn: sprayerOn,
          isAutomationEnabled: isAutomationEnabled,
        ));
      }
    });
  }
}
