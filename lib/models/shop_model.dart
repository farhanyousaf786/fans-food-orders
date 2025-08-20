import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String floor;
  final String gate;
  final String stadiumId;
  final List<String> admins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.floor,
    required this.gate,
    required this.stadiumId,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'floor': floor,
      'gate': gate,
      'stadiumId': stadiumId,
      'admins': admins,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      floor: data['floor'] ?? '',
      gate: data['gate'] ?? '',
      stadiumId: data['stadiumId'] ?? '',
      admins: List<String>.from(data['admins'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt'] as String),
    );
  }

  bool isAdmin(String userId) {
    return admins.contains(userId);
  }
}
