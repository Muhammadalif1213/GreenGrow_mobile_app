import 'package:equatable/equatable.dart';
import '../../../data/models/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<LocationModel> locations;

  const LocationLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class SingleLocationLoaded extends LocationState {
  final LocationModel location;

  const SingleLocationLoaded(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
} 