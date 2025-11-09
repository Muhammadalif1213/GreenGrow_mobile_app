import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllLocations extends LocationEvent {}

class FetchNearbyLocations extends LocationEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const FetchNearbyLocations({
    required this.latitude,
    required this.longitude,
    this.radius = 10,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class FetchLocationById extends LocationEvent {
  final int id;

  const FetchLocationById(this.id);

  @override
  List<Object?> get props => [id];
}

class FetchLocationsByGreenhouseId extends LocationEvent {
  final int greenhouseId;

  const FetchLocationsByGreenhouseId(this.greenhouseId);

  @override
  List<Object?> get props => [greenhouseId];
} 