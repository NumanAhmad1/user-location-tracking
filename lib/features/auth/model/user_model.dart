import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String age;
  final UserLocation? location;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.age,
    this.location,
  });

  /// Convert Firebase User to UserModel
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      age: '', // Age is not provided by Firebase Auth
      location: null,
    );
  }

  /// Convert a Firestore document (Map) into a UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      age: json['age'] ?? '',
      location:
          json['location'] is Map<String, dynamic>
              ? UserLocation.fromJson(json['location'])
              : null,
    );
  }

  /// Convert UserModel to a JSON format (Map)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'age': age,
      'location': location?.toJson(),
    };
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({required this.latitude, required this.longitude});

  /// Convert a Firestore document (Map) into a UserLocation
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert UserLocation to a JSON format (Map)
  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
