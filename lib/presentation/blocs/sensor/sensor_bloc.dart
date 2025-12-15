import 'package:flutter_bloc/flutter_bloc.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';
import '../../../data/repositories/sensor_repository.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final SensorRepository _sensorRepository;

  SensorBloc(this._sensorRepository) : super(SensorInitial()) {
    // Daftarkan event handler
    on<FetchLatestSensorData>(_onFetchLatestSensorData);
    on<FetchSensorHistory>(_onFetchSensorHistory);
  }

  Future<void> _onFetchLatestSensorData(
    FetchLatestSensorData event,
    Emitter<SensorState> emit,
  ) async {
    emit(SensorLoading());
    try {
      // Panggil fungsi repository yang sudah benar
      final data = await _sensorRepository.getLatestSensorData();

      // Kirim state sukses dengan data yang baru
      emit(SensorLoaded(data));
    } catch (e) {
      emit(SensorError(e.toString()));
    }
  }

  Future<void> _onFetchSensorHistory(
    FetchSensorHistory event,
    Emitter<SensorState> emit,
  ) async {
    emit(SensorLoading());
    try {
      final logs = await _sensorRepository.getSensorLogs();
      emit(SensorHistoryLoaded(logs));
    } catch (e) {
      emit(SensorError(e.toString()));
    }
  }
}
