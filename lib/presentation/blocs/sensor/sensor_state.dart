import 'package:equatable/equatable.dart';
import '../../../data/models/sensor_data_model.dart';

abstract class SensorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SensorInitial extends SensorState {}

class SensorLoading extends SensorState {}

// State sukses, membawa SATU SensorDataModel
class SensorLoaded extends SensorState {
  final SensorDataModel sensorData;
  SensorLoaded(this.sensorData);
}

// State error
class SensorError extends SensorState {
  final String message;
  SensorError(this.message);
}