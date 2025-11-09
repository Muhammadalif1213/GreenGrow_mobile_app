import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/repositories/location_repository.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/location/location_event.dart';
import '../../blocs/location/location_state.dart';
import '../../../data/models/location_model.dart';

class GreenhouseMapScreen extends StatefulWidget {
  const GreenhouseMapScreen({super.key});

  @override
  State<GreenhouseMapScreen> createState() => _GreenhouseMapScreenState();
}

class _GreenhouseMapScreenState extends State<GreenhouseMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _currentPosition;

  // Default location (Jakarta)
  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocations();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _fetchLocations() {
    context.read<LocationBloc>().add(FetchAllLocations());
  }

  void _updateMarkers(List<LocationModel> locations) {
    if (!mounted) return;
    setState(() {
      _markers = locations.map((location) {
        return Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showLocationDetails(location),
            child: Column(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    });
  }

  void _showLocationDetails(LocationModel location) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Greenhouse: ${location.greenhouseName}'),
            const SizedBox(height: 4),
            Text('Alamat: ${location.address}'),
            if (location.distance != null) ...[
              const SizedBox(height: 4),
              Text('Jarak: ${location.distance!.toStringAsFixed(2)} km'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Greenhouse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocations,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(_currentPosition!, 15);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            _updateMarkers(state.locations);
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition ?? _defaultLocation,
                  initialZoom: 12,
                  onTap: (_, __) {
                    // Handle map tap if needed
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.greengrow_app',
                  ),
                  MarkerLayer(markers: _markers),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (state is LocationLoaded && state.locations.isEmpty)
                const Center(
                  child: Text(
                    'Tidak ada lokasi greenhouse yang tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
} 