import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../data/models/sensor_data_model.dart';
import '../../../data/repositories/device_control_repository.dart';

part 'device_control_event.dart';
part 'device_control_state.dart';

class DeviceControlBloc
    extends Bloc<DeviceControlEvent, DeviceControlState> {
  final DeviceControlRepository _repository;

  DeviceControlBloc(this._repository) : super(DeviceControlInitial()) {
    // Daftarkan semua event handler
    on<DeviceControlFetchStatus>(_onFetchStatus);
    on<DeviceControlRequested>(_onControlRequested);
    on<DeviceControlAutomationToggled>(_onAutomationToggled);
    on<DeviceControlBlowerToggled>(_onBlowerToggled);
  }

  Future<void> _onBlowerToggled(
    DeviceControlBlowerToggled event,
    Emitter<DeviceControlState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceControlStatus) {
      // Tampilkan loading di UI, tapi tetap simpan data lama
      emit(currentState.copyWith(message: 'Memperbarui blower...'));
    }

    try {
      // Panggil fungsi repository BARU kita
      await _repository.setBlowerStatus(newStatus: event.isEnabled);

      // Setelah berhasil, panggil API status lagi untuk data terupdate
      add(DeviceControlFetchStatus());
      
    } catch (e) {
      emit(DeviceControlError(e.toString()));
    }
  }


  Future<void> _onAutomationToggled(
    DeviceControlAutomationToggled event,
    Emitter<DeviceControlState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceControlStatus) {
      // Tampilkan loading di UI, tapi tetap simpan data lama
      emit(currentState.copyWith(message: 'Memperbarui automation...'));
    }

    try {
      // Panggil fungsi repository BARU kita
      await _repository.setAutomationStatus(newStatus: event.isEnabled);

      // Setelah berhasil, panggil API status lagi untuk data terupdate
      add(DeviceControlFetchStatus());
      
    } catch (e) {
      emit(DeviceControlError(e.toString()));
    }
  }

  /// Handler untuk mengambil status konfigurasi terbaru
  Future<void> _onFetchStatus(
    DeviceControlFetchStatus event,
    Emitter<DeviceControlState> emit,
  ) async {
    // Hanya emit loading jika state saat ini bukan status (saat pertama kali load)
    if (state is! DeviceControlStatus) {
      emit(DeviceControlLoading());
    }
    
    try {
      // Panggil fungsi repository baru kita
      final ConfigModel config = await _repository.getDeviceStatus();

      // Emit state baru dengan data dari ConfigModel
      emit(DeviceControlStatus(
        blowerOn: config.blower,
        isAutomationEnabled: config.automation,
        maxTemp: config.maxTemp,
      ));
    } catch (e) {
      emit(DeviceControlError(e.toString()));
    }
  }

  /// Handler untuk mengirim perintah ON/OFF
  Future<void> _onControlRequested(
    DeviceControlRequested event,
    Emitter<DeviceControlState> emit,
  ) async {
    // Ambil state saat ini untuk tahu status terakhir
    final currentState = state;
    if (currentState is DeviceControlStatus) {
      // Tampilkan loading di UI, tapi tetap simpan data lama
      emit(currentState.copyWith(message: 'Mengirim perintah...'));
    }

    try {
      // Asumsi: Repository Anda punya fungsi setDeviceStatus
      // Sesuaikan nama fungsi ini jika berbeda di repository Anda
      await _repository.setDeviceStatus(
        device: event.deviceType,
        status: event.action,
      );

      // Setelah berhasil, panggil API status lagi untuk data terupdate
      add(DeviceControlFetchStatus());
      
    } catch (e) {
      emit(DeviceControlError(e.toString()));
    }
  }
}