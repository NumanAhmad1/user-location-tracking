import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_tracker_app/features/chat/view/chat_groups.dart';
import 'package:location_tracker_app/features/home/controller/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  bool _initialLocationSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().checkLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Live Location Tracker"),
        actions: [
          BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.userLocation != null && !_initialLocationSet) {
                _mapController.move(state.userLocation!, 15.0);
                _initialLocationSet = true;
              }
            },
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isTracking ? Icons.location_on : Icons.location_off,
                ),
                onPressed:
                    state.isTracking
                        ? null
                        : () =>
                            context.read<HomeCubit>().checkLocationPermission(),
                tooltip:
                    state.isTracking ? 'Tracking active' : 'Start tracking',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.messenger),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatGroupsScreen()),
              );
            },
            tooltip: 'Messages',
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.userLocation == null && state.isTracking) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Acquiring location...'),
                ],
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.userLocation ?? const LatLng(0, 0),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.live_location_tracker',
                  ),
                  if (state.userLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.userLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (state.destination != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.destination!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.flag,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (state.polylinePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.polylinePoints,
                          color: Colors.blue.withValues(alpha: 0.7),
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${state.locationStatus}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                state.locationStatus.contains('error')
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),
                        if (state.userLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current: ${state.userLocation!.latitude.toStringAsFixed(6)}, '
                            '${state.userLocation!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        if (state.destination != null &&
                            state.distanceToDestination > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Distance: ${(state.distanceToDestination / 1000).toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        if (state.locationStatus.contains('error')) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    context
                                        .read<HomeCubit>()
                                        .getRouteWithRetry(),
                            child: const Text('Retry Route Calculation'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () {
                  if (state.userLocation != null) {
                    _mapController.move(
                      state.userLocation!,
                      _mapController.camera.zoom,
                    );
                  }
                },
                tooltip: 'Center on my location',
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'btn2',
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  LocationData? locationData = await LocationSearch.show(
                    onError: (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    },
                    searchBarHintText:
                        state.searchedLocation ?? 'Search location',
                    context: context,
                    mode: Mode.fullscreen,
                    lightAddress: true,
                    userAgent: UserAgent(
                      appName: 'Location Search Example',
                      email: 'support@myapp.com',
                    ),
                  );

                  if (locationData != null) {
                    log(locationData.toString());
                    log(locationData.address.toString());
                    log("${locationData.latitude}, ${locationData.longitude}");

                    context.read<HomeCubit>().setDestination(
                      LatLng(locationData.latitude, locationData.longitude),
                    );
                  }
                },
                tooltip: 'Set destination',
                child: const Icon(Icons.search),
              ),
            ],
          );
        },
      ),
    );
  }
}
