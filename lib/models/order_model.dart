import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'order_status.dart';

class OrderModel extends Equatable {
  final String id;
  final List<Map<String, dynamic>> cart;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final Map<String, dynamic> userInfo;
  final String stadiumId;
  final String shopId;
  final String orderId;
  final OrderStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> seatInfo;

  const OrderModel({
    required this.id,
    required this.cart,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.userInfo,
    required this.stadiumId,
    required this.shopId,
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.seatInfo,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      cart: List<Map<String, dynamic>>.from(data['cart'] ?? []),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      userInfo: Map<String, dynamic>.from(data['userInfo'] ?? {}),
      stadiumId: data['stadiumId'] ?? '',
      shopId: data['shopId'] ?? '',
      orderId: data['orderId'] ?? '',
      status: OrderStatus.values[data['status'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      seatInfo: Map<String, dynamic>.from(data['seatInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cart': cart,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'userInfo': userInfo,
      'stadiumId': stadiumId,
      'shopId': shopId,
      'orderId': orderId,
      'status': status.index,
      'createdAt': createdAt,
      'seatInfo': seatInfo,
    };
  }

  @override
  List<Object?> get props => [
        id,
        cart,
        subtotal,
        deliveryFee,
        discount,
        total,
        userInfo,
        stadiumId,
        shopId,
        orderId,
        status,
        createdAt,
        seatInfo,
      ];
}
