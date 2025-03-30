// home_state.dart
part of 'home_cubit.dart';

class HomeState {
  final LatLng? userLocation;
  final LatLng? destination;
  final List<LatLng> polylinePoints;
  final bool isTracking;
  final String locationStatus;
  final double distanceToDestination;
  final int currentIndex;
  final String? searchedLocation;

  const HomeState({
    this.userLocation,
    this.destination,
    this.currentIndex = 0,
    this.polylinePoints = const [],
    this.isTracking = false,
    this.locationStatus = 'Waiting for location...',
    this.distanceToDestination = 0.0,
    this.searchedLocation,
  });

  HomeState copyWith({
    LatLng? userLocation,
    LatLng? destination,
    List<LatLng>? polylinePoints,
    bool? isTracking,
    String? locationStatus,
    int? currentIndex,
    double? distanceToDestination,
    String? searchedLocation,
  }) {
    return HomeState(
      userLocation: userLocation ?? this.userLocation,
      destination: destination ?? this.destination,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      isTracking: isTracking ?? this.isTracking,
      locationStatus: locationStatus ?? this.locationStatus,
      currentIndex: currentIndex ?? this.currentIndex,
      distanceToDestination:
          distanceToDestination ?? this.distanceToDestination,
      searchedLocation: searchedLocation ?? this.searchedLocation,
    );
  }
}
