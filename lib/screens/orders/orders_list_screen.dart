import 'package:flutter/material.dart';
import '../../models/order_status.dart';
import '../../models/shop_model.dart';
import 'widgets/order_list.dart';

class OrdersListScreen extends StatefulWidget {
  final ShopModel shop;

  const OrdersListScreen({super.key, required this.shop});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus> _statusTabs = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onStatusUpdated() {
    // This will trigger a refresh of the order list
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders - ${widget.shop.name}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'ALL'),
            ..._statusTabs.map((status) => Tab(
                  text: status.toString().split('.').last.toUpperCase(),
                )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Orders Tab
          OrderList(
            shop: widget.shop,
            onStatusUpdated: _onStatusUpdated,
          ),
          // Status-specific tabs
          ..._statusTabs.map((status) => OrderList(
                shop: widget.shop,
                statusFilter: status,
                onStatusUpdated: _onStatusUpdated,
              )),
        ],
      ),
    );
  }

}
