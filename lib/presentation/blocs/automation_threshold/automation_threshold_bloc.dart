import 'package:flutter_bloc/flutter_bloc.dart';
import 'automation_threshold_event.dart';
import 'automation_threshold_state.dart';
import '../../../data/repositories/automation_threshold_repository.dart';

class AutomationThresholdBloc extends Bloc<AutomationThresholdEvent, AutomationThresholdState> {
  final AutomationThresholdRepository repository;

  AutomationThresholdBloc(this.repository) : super(AutomationThresholdInitial()) {
    on<FetchThresholds>((event, emit) async {
      emit(AutomationThresholdLoading());
      try {
        final thresholds = await repository.getThresholds();
        emit(AutomationThresholdLoaded(thresholds));
      } catch (e) {
        emit(AutomationThresholdError(e.toString()));
      }
    });

    on<UpsertThreshold>((event, emit) async {
      emit(AutomationThresholdLoading());
      try {
        await repository.upsertThreshold(
          parameter: event.parameter,
          deviceType: event.deviceType,
          // minValue: event.minValue,
          maxValue: event.maxValue,
        );
        emit(AutomationThresholdSuccess());
        // Fetch latest after upsert
        final thresholds = await repository.getThresholds();
        emit(AutomationThresholdLoaded(thresholds));
      } catch (e) {
        emit(AutomationThresholdError(e.toString()));
      }
    });
  }
} 