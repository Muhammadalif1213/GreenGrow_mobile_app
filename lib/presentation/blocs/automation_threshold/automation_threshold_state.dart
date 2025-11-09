import 'package:equatable/equatable.dart';
import '../../../data/models/automation_threshold_model.dart';

abstract class AutomationThresholdState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AutomationThresholdInitial extends AutomationThresholdState {}

class AutomationThresholdLoading extends AutomationThresholdState {}

class AutomationThresholdLoaded extends AutomationThresholdState {
  final List<AutomationThresholdModel> thresholds;
  AutomationThresholdLoaded(this.thresholds);

  @override
  List<Object?> get props => [thresholds];
}

class AutomationThresholdSuccess extends AutomationThresholdState {}

class AutomationThresholdError extends AutomationThresholdState {
  final String message;
  AutomationThresholdError(this.message);

  @override
  List<Object?> get props => [message];
} 