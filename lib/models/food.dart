import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';



// ignore: must_be_immutable
class Food extends Equatable {
  final String id;
  final List<String> allergens;
  final String category;
  final Map<String, String> categoryMap;
  final DateTime createdAt;
  final Map<String, dynamic> customization;
  final String description;
  final Map<String, String> descriptionMap;
  final List<Map<String, dynamic>> extras;
  final List<String> images;
  final bool isAvailable;
  final String name;
  final Map<String, String> nameMap;
  final Map<String, dynamic> nutritionalInfo;
  final int preparationTime;
  final double price;
  final List<Map<String, dynamic>> sauces;
  final List<String> shopIds;
  final String stadiumId;
  final List<Map<String, dynamic>> sizes;
  final List<Map<String, dynamic>> toppings;
  final DateTime updatedAt;
  final Map<String, bool> foodType;

  int quantity = 1;

  Food({
    required this.id,
    required this.allergens,
    required this.category,
    this.categoryMap = const {},
    required this.createdAt,
    required this.customization,
    required this.description,
    this.descriptionMap = const {},
    required this.extras,
    required this.images,
    required this.isAvailable,
    required this.name,
    this.nameMap = const {},
    required this.nutritionalInfo,
    required this.preparationTime,
    required this.price,
    required this.sauces,
    required this.shopIds,
    required this.stadiumId,
    required this.sizes,
    required this.toppings,
    required this.updatedAt,
    required this.foodType,
    this.quantity = 1,
  });

  factory Food.fromMap(String id, Map<String, dynamic> map) {
    return Food(
      id: id,
      allergens: (map['allergens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: map['category'] ?? '',
      categoryMap: (map['categoryMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      customization: (map['customization'] as Map<String, dynamic>?) ?? {},
      description: map['description'] ?? '',
      descriptionMap: (map['descriptionMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      extras: (map['extras'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isAvailable: map['isAvailable'] ?? true,
      name: map['name'] ?? '',
      nameMap: (map['nameMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      nutritionalInfo: (map['nutritionalInfo'] as Map<String, dynamic>?) ?? {},
      preparationTime: map['preparationTime'] ?? 15,
      price: (map['price'] ?? 0).toDouble(),
      sauces: (map['sauces'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      shopIds: List<String>.from(map['shopIds'] ?? []),
      stadiumId: map['stadiumId'] ?? '',
      sizes: (map['sizes'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      toppings: (map['toppings'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      foodType: (map['foodType'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {
            'halal': false,
            'kosher': false,
            'vegan': false,
          },
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'allergens': allergens,
      'category': category,
      'createdAt': createdAt,
      'customization': customization,
      'description': description,
      'descriptionMap': descriptionMap,
      'extras': extras,
      'images': images,
      'isAvailable': isAvailable,
      'name': name,
      'nameMap': nameMap,
      'nutritionalInfo': nutritionalInfo,
      'preparationTime': preparationTime,
      'price': price,
      'sauces': sauces,
      'shopIds': shopIds,
      'stadiumId': stadiumId,
      'sizes': sizes,
      'toppings': toppings,
      'updatedAt': updatedAt,
      'foodType': foodType,
    };
  }



  // Localization helpers
  String nameFor(String languageCode) {
    final value = nameMap[languageCode];
    // if (value != null && value.trim().isNotEmpty) return value;
    return value ??'';
  }

  String descriptionFor(String languageCode) {
    final value = descriptionMap[languageCode];
    // if (value != null && value.trim().isNotEmpty) return value;
    return value ??'';
  }

  String categoryFor(String languageCode) {
    final value = categoryMap[languageCode];
    // if (value != null && value.trim().isNotEmpty) return value;
    return value??'';
  }

  @override
  List<Object> get props => [name, createdAt];
}
