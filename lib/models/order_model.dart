import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'food.dart';
import 'order_status.dart';

class OrderModel extends Equatable {
  final List<Food> cart;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final double tipAmount;
  final bool isTipAdded;
  final Map<String, dynamic> userInfo;
  final String stadiumId;
  final String shopId;
  final String orderId;
  final OrderStatus status;
  final Timestamp? createdAt;
  final Timestamp? deliveryTime;
  final Map<String, dynamic> seatInfo;
  final String? deliveryUserId;
  final String orderCode;
  final GeoPoint? location;
  final GeoPoint? customerLocation;

  final String? id;

  OrderModel({
    this.id,
    required this.cart,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.tipAmount,
    required this.isTipAdded,
    required this.userInfo,
    required this.stadiumId,
    required this.shopId,
    required this.orderId,
    required this.status,
    required this.createdAt,
    this.deliveryTime,
    required this.seatInfo,
    this.deliveryUserId,
    required this.orderCode,
    this.location,
    this.customerLocation,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(doc.id, data);
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      cart: List<Food>.from(
        map['cart']?.map(
          (x) => Food.fromMap(x['id'] as String, x as Map<String, dynamic>),
        ) ??
        [],
      ),
      subtotal: (map['subtotal'] ?? 0) * 1.0,
      deliveryFee: (map['deliveryFee'] ?? 0) * 1.0,
      discount: (map['discount'] ?? 0) * 1.0,
      total: (map['total'] ?? 0) * 1.0,
      tipAmount: (map['tipAmount'] ?? 0) * 1.0,
      isTipAdded: map['isTipAdded'] ?? false,
      userInfo: map['userInfo'] ?? {},
      stadiumId: map['stadiumId'] ?? '',
      shopId: map['shopId'] ?? '',
      orderId: map['orderId'] ?? '',
      status: OrderStatus.values[map['status'] ?? 0],
      createdAt: map['createdAt'] as Timestamp?,
      deliveryTime: map['deliveryTime'] as Timestamp?,
      seatInfo: map['seatInfo'] ?? {},
      deliveryUserId: map['deliveryUserId'],
      orderCode: map['orderCode'] ?? '',
      location: map['location'] as GeoPoint?,
      customerLocation: map['customerLocation'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cart': cart.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'tipAmount': tipAmount,
      'isTipAdded': isTipAdded,
      'userInfo': userInfo,
      'stadiumId': stadiumId,
      'shopId': shopId,
      'orderId': orderId,
      'status': status.index,
      'createdAt': createdAt,
      'deliveryTime': deliveryTime,
      'seatInfo': seatInfo,
      'deliveryUserId': deliveryUserId,
      'orderCode': orderCode,
      'location': location,
      'customerLocation': customerLocation,
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
    tipAmount,
    isTipAdded,
    userInfo,
    stadiumId,
    shopId,
    orderId,
    status,
    createdAt,
    deliveryTime,
    seatInfo,
    deliveryUserId,
    orderCode,
    location,
    customerLocation,
  ];
}
