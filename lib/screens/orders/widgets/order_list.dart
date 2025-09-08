import 'package:fans_food_order/translations/translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';


import '../../../models/order.dart';
import '../../../models/shop_model.dart';
import '../../../models/order_status.dart';
import 'order_card.dart';

class OrderList extends StatelessWidget {
  final ShopModel shop;
  final OrderStatus? statusFilter;
  final VoidCallback? onStatusUpdated;

  const OrderList({
    super.key,
    required this.shop,
    this.statusFilter,
    this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${Translate.get('error_prefix')}${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList();

        if (orders.isEmpty) {
          return Center(child: Text(Translate.get('noOrdersFound')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              onStatusUpdated: onStatusUpdated,
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getOrdersStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('orders')
        .where('shopId', isEqualTo: shop.id)
        .orderBy('createdAt', descending: true);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter!.index);
    }

    return query.snapshots();
  }
}

