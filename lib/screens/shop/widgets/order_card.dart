import 'dart:math' show min;
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderStatus) onStatusUpdate;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context),
            const SizedBox(height: 16),
            _buildOrderItems(context),
            const Divider(height: 24),
            _buildOrderTotal(context),
            if (order.seatInfo.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDeliveryInfo(context),
            ],
            const SizedBox(height: 16),
            _buildStatusSection(context),
          ],
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
              'Order #${order.id.substring(0, min(order.id.length, 6))}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Created at: ${order.createdAt.toLocal().toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ) ?? TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            order.status.name.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.cart.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'] ?? 'Unknown Item',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'x${item['quantity'] ?? 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildOrderTotal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ) ?? TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          '\$${order.total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ) ?? TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
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

  Widget _buildDeliveryInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildSeatInfoRow('Section', order.seatInfo['section'] ?? '', context),
              _buildSeatInfoRow('Row', order.seatInfo['row'] ?? '', context),
              _buildSeatInfoRow('Seat', order.seatInfo['seatNo'] ?? '', context),
              _buildSeatInfoRow('Roof', order.seatInfo['roofNo'] ?? '', context),
              if (order.seatInfo['seatDetails'] != null)
                _buildSeatInfoRow('Details', order.seatInfo['seatDetails'], context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Update Status:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        PopupMenuButton<OrderStatus>(
          onSelected: (OrderStatus status) {
            if (status != order.status) {
              onStatusUpdate(status);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  size: 18,
                  color: _getStatusColor(order.status),
                ),
                const SizedBox(width: 8),
                Text(
                  order.status.name,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: _getStatusColor(order.status),
                ),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) => [
            _buildStatusMenuItem(context, OrderStatus.pending, Icons.access_time, 'Pending'),
            _buildStatusMenuItem(context, OrderStatus.preparing, Icons.restaurant, 'Preparing'),
            _buildStatusMenuItem(context, OrderStatus.delivering, Icons.delivery_dining, 'Delivering'),
            _buildStatusMenuItem(context, OrderStatus.delivered, Icons.check_circle, 'Delivered'),
            _buildStatusMenuItem(context, OrderStatus.cancelled, Icons.cancel, 'Cancelled'),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  PopupMenuItem<OrderStatus> _buildStatusMenuItem(BuildContext context, OrderStatus status, IconData icon, String label) {
    return PopupMenuItem<OrderStatus>(
      value: status,
      child: Row(
        children: [
          Icon(icon, size: 20, color: _getStatusColor(status)),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
