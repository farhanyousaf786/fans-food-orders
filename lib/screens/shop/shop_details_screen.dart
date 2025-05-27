import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shop_model.dart';
import '../../models/order_model.dart';
import '../../models/order_status.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ShopDetailsScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopDetailsScreen({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('${shop.name} Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('shopId', isEqualTo: shop.id)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList() ??
              [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                onStatusUpdate: (OrderStatus newStatus) async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(order.id)
                        .update({'status': newStatus.index});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order status updated to ${newStatus.name}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating order status: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }


}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderStatus) onStatusUpdate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    order.status.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const Divider(),
            Text('Items:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...order.cart.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name'] ?? 'Unknown Item'),
                      Text('x${item['quantity'] ?? 1}'),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(
                  '${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.seatInfo.isNotEmpty) ...[              
              Text('Delivery to:', style: Theme.of(context).textTheme.titleSmall),
              Text('Section ${order.seatInfo['section'] ?? ''}, Row ${order.seatInfo['row'] ?? ''}, Seat ${order.seatInfo['seat'] ?? ''}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: Theme.of(context).textTheme.titleSmall),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != order.status) {
                      onStatusUpdate(newStatus);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
