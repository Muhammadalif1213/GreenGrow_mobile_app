import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc(this.repository) : super(LocationInitial()) {
    on<FetchAllLocations>((event, emit) async {
      emit(LocationLoading());
      try {
        final locations = await repository.getAllLocations();
        emit(LocationLoaded(locations));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<FetchNearbyLocations>((event, emit) async {
      emit(LocationLoading());
      try {
        final locations = await repository.getNearbyLocations(
          latitude: event.latitude,
          longitude: event.longitude,
          radius: event.radius,
        );
        emit(LocationLoaded(locations));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<FetchLocationById>((event, emit) async {
      emit(LocationLoading());
      try {
        final location = await repository.getLocationById(event.id);
        emit(SingleLocationLoaded(location));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<FetchLocationsByGreenhouseId>((event, emit) async {
      emit(LocationLoading());
      try {
        final locations = await repository.getLocationsByGreenhouseId(event.greenhouseId);
        emit(LocationLoaded(locations));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });
  }
} 