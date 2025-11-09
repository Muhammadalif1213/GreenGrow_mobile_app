import 'package:equatable/equatable.dart';

abstract class AutomationThresholdEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchThresholds extends AutomationThresholdEvent {}

class UpsertThreshold extends AutomationThresholdEvent {
  final String parameter;
  final String deviceType;
  final double? minValue;
  final double? maxValue;

  UpsertThreshold({
    required this.parameter,
    required this.deviceType,
    this.minValue,
    this.maxValue,
  });

  @override
  List<Object?> get props => [parameter, deviceType, minValue, maxValue];
} 