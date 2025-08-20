import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String code;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> shopIds;

  UserModel({
    required this.id,
    required this.code,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.shopIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      code: data['code'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      shopIds: List<String>.from(data['shopsId'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? code,
    String? email,
    String? name,
    List<String>? shopIds,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      code: code ?? this.code,
      email: email ?? this.email,
      name: name ?? this.name,
      shopIds: shopIds ?? this.shopIds,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
