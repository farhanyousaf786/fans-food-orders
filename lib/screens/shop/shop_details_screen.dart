import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../models/order_status.dart';
import '../../models/shop_model.dart';
import 'widgets/order_card.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsScreen({Key? key, required this.shop}) : super(key: key);

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<OrderStatus?> _statusTabs = [
    null, // All
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.shop.name} Orders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false, // Ensures even spacing and removes weird padding
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Preparing'),
            Tab(text: 'Delivering'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusTabs.map((status) => _buildOrderList(status)).toList(),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus? filterStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('shopId', isEqualTo: widget.shop.id)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data?.docs
                .map((doc) => OrderModel.fromFirestore(doc))
                .toList() ??
            [];

        final filteredOrders = filterStatus == null
            ? allOrders
            : allOrders.where((order) => order.status == filterStatus).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'No ${filterStatus?.name ?? 'Orders'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Orders will appear here when customers place them',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
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
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating order status: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
