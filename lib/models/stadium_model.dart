import 'package:cloud_firestore/cloud_firestore.dart';

class StadiumModel {
  final String id;
  final String name;
  final String about;
  final String location;
  final String imageUrl;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  StadiumModel({
    required this.id,
    required this.name,
    required this.about,
    required this.location,
    required this.imageUrl,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StadiumModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StadiumModel(
      id: doc.id,
      name: data['name'] ?? '',
      about: data['about'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      capacity: data['capacity'] ?? 0,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt'] as String),
    );
  }
}
