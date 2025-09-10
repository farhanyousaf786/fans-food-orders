import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food.dart';
import 'models/order.dart' as model;

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Stream<List<model.OrderModel>> streamOrders(List<String> shopIds) {


    return _db
        .collection('orders')
        .where('shopId', whereIn: shopIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs
              .map((doc) => model.OrderModel.fromMap(doc.id, doc.data()))
              .toList(),
    )
        .handleError((error) {
      debugPrint('Error streaming orders: ${error.toString()}');
      throw error;
    });
  }

  // Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
  //   try {
  //     await _db.collection('orders').doc(orderId).update({
  //       'status': status.index,
  //     });
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     rethrow;
  //   }
  //}

  // Future<void> updateOrderLocation(String orderId, GeoPoint location) async {
  //   try {
  //     await _db.collection('orders').doc(orderId).update({
  //       'location': location,
  //     });
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     rethrow;
  //   }
  // }

  Stream<model.OrderModel> streamOrderById(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => model.OrderModel.fromMap(doc.id, doc.data()!))
        .handleError((error) {
      debugPrint('Error streaming order: ${error.toString()}');
      throw error;
    });
  }
}

