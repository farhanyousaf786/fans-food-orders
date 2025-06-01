import 'dart:math' show min;
import 'package:fans_food_order/screens/shop/widgets/created_at_info.dart';
import 'package:fans_food_order/screens/shop/widgets/delivery_info_section.dart';
import 'package:fans_food_order/screens/shop/widgets/user_info_section.dart';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final Function(OrderStatus) onStatusUpdate;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CreatedAtInfo(createdAt: widget.order.createdAt),

              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: _buildOrderHeader(context),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                _buildOrderItems(context),
                const Divider(height: 24),
                _buildOrderTotal(context),
                const SizedBox(height: 16),
                _buildFoodTypeInfo(context),
                const SizedBox(height: 16),
                _buildDeliveryInfo(context),
                const SizedBox(height: 16),
                _buildUserInfo(context),
               
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildOrderHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${widget.order.id.substring(0, min(widget.order.id.length, 6))}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          _buildStatusSection(context),
        ],
      ),
    ],
  );
}


  Widget _buildOrderItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.order.cart.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['name'] ?? 'Unknown Item',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text('x${item['quantity'] ?? 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderTotal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total:', style: Theme.of(context).textTheme.labelLarge),
        Text(
          '\$${widget.order.total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    final seat = widget.order.seatInfo;
    if (seat.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeliveryInfoSection(seatInfo: seat, subtotal: widget.order.subtotal),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final user = widget.order.userInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserInfoSection(userInfo: user),
      ],
    );
  }


  Widget _buildFoodTypeInfo(BuildContext context) {
  final foodType = widget.order.foodType;
  if (foodType == null || foodType.isEmpty) return const SizedBox();

  final labels = {
    'halal': 'Halal',
    'kosher': 'Kosher',
    'vegan': 'Vegan',
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Food Type', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Column(
        children: labels.entries.map((entry) {
          final bool? value = foodType[entry.key];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  value == true ? Icons.check_circle : Icons.cancel,
                  color: value == true ? Colors.green : Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(entry.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        )),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}


Widget _buildStatusSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Update Status:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<OrderStatus>(
          onSelected: (status) => widget.onStatusUpdate(status),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(widget.order.status),
                  size: 16,
                  color: _getStatusColor(widget.order.status),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.order.status.name,
                  style: TextStyle(
                    color: _getStatusColor(widget.order.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          itemBuilder: (context) => OrderStatus.values
              .map((status) => PopupMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 18,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 6),
                        Text(status.name),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    ),
  );
}


  Widget _buildSeatInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blueAccent;
      case OrderStatus.delivering:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}