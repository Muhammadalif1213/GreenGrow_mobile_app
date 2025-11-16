import 'package:equatable/equatable.dart';

abstract class SensorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLatestSensorData extends SensorEvent {}
