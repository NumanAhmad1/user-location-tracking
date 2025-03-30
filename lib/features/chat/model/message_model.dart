import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String senderName;
  final String message;
  final bool isLocation;
  final String lat;
  final String lng;
  final DateTime? timestamp;

  MessageModel({
    required this.senderId,
    required this.senderName,
    this.message = '',
    this.isLocation = false,
    this.lat = '',
    this.lng = '',
    this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      isLocation: json['isLocation'] ?? false,
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'isLocation': isLocation,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
