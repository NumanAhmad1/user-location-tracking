// home_cubit.dart
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OpenRouteService _ors = OpenRouteService(
    apiKey: '5b3ce3597851110001cf62486905a63240744623b657f38a301a8ed6',
  );

  StreamSubscription<Position>? _positionStreamSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomeCubit() : super(const HomeState());

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> checkLocationPermission() async {
    emit(state.copyWith(locationStatus: 'Checking permissions...'));

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(locationStatus: 'Location services are disabled'));
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      emit(state.copyWith(locationStatus: 'Requesting permissions...'));
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(locationStatus: 'Location permissions denied'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          locationStatus: 'Location permissions permanently denied',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isTracking: true,
        locationStatus: 'Getting current location...',
      ),
    );

    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      updateUserLocation(lastPosition);

      await updateUserLocationOnFirebase(_auth.currentUser!.uid, lastPosition);
    }

    await startTracking();
  }

  Future<void> startTracking() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      updateUserLocation(position);

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen(
        (position) async {
          updateUserLocation(position);
          if (state.destination != null) {
            calculateDistanceToDestination();
            await getRouteWithRetry();
            await updateUserLocationOnFirebase(
              _auth.currentUser!.uid,
              position,
            );
          }
        },
        onError: (error) {
          emit(state.copyWith(locationStatus: 'Location error: $error'));
        },
      );

      emit(state.copyWith(isTracking: true, locationStatus: 'Tracking active'));
    } catch (e) {
      emit(state.copyWith(locationStatus: 'Error starting tracking: $e'));
    }
  }

  void updateUserLocation(Position position) {
    if (!_isValidPosition(position)) {
      emit(state.copyWith(locationStatus: 'Invalid location data received'));
      return;
    }

    final newLocation = _sanitizeCoordinates(
      LatLng(position.latitude, position.longitude),
    );

    emit(
      state.copyWith(
        userLocation: newLocation,
        locationStatus: 'Location updated',
      ),
    );
  }

  bool _isValidPosition(Position position) {
    return position.latitude >= -90 &&
        position.latitude <= 90 &&
        position.longitude >= -180 &&
        position.longitude <= 180;
  }

  LatLng _sanitizeCoordinates(LatLng coord) {
    return LatLng(
      coord.latitude.clamp(-90.0, 90.0),
      coord.longitude.clamp(-180.0, 180.0),
    );
  }

  void calculateDistanceToDestination() {
    if (state.userLocation == null || state.destination == null) return;

    final distance = Geolocator.distanceBetween(
      state.userLocation!.latitude,
      state.userLocation!.longitude,
      state.destination!.latitude,
      state.destination!.longitude,
    );

    emit(state.copyWith(distanceToDestination: distance));
  }

  Future<void> getRouteWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await getRoute();
        return;
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          emit(
            state.copyWith(
              locationStatus: 'Route error: ${e.toString()}',
              polylinePoints: [],
            ),
          );
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> getRoute() async {
    if (state.userLocation == null || state.destination == null) return;

    if (!_isValidCoordinate(state.userLocation!) ||
        !_isValidCoordinate(state.destination!)) {
      emit(state.copyWith(locationStatus: 'Invalid coordinates for routing'));
      return;
    }

    try {
      final routeCoordinates = await _ors.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
          latitude: state.userLocation!.latitude,
          longitude: state.userLocation!.longitude,
        ),
        endCoordinate: ORSCoordinate(
          latitude: state.destination!.latitude,
          longitude: state.destination!.longitude,
        ),
        profileOverride: ORSProfile.drivingCar,
      );

      emit(
        state.copyWith(
          polylinePoints:
              routeCoordinates
                  .map((coord) => LatLng(coord.latitude, coord.longitude))
                  .toList(),
          locationStatus: 'Route calculated successfully',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  bool _isValidCoordinate(LatLng coord) {
    return coord.latitude >= -90 &&
        coord.latitude <= 90 &&
        coord.longitude >= -180 &&
        coord.longitude <= 180;
  }

  void setDestination(LatLng destination) {
    final sanitized = _sanitizeCoordinates(destination);
    emit(
      state.copyWith(destination: sanitized, locationStatus: 'Destination set'),
    );
    getRouteWithRetry();
  }

  void updateIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  Future<void> updateUserLocationOnFirebase(
    String userId,
    Position position,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });

      log("User location updated successfully");
    } catch (e) {
      log("Error updating user location: $e");
    }
  }
}
