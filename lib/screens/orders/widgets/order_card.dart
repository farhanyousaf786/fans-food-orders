import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../screens/order_details_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onStatusUpdated;

  const OrderCard({
    super.key,
    required this.order,
    this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status, theme).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(order.status).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(order.status, theme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(order.createdAt),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                '${order.cart.length} items • ${_formatPrice(order.total)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (order.seatInfo.isNotEmpty)
                ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.chair,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${order.seatInfo['section'] ?? 'Section'} ${order.seatInfo['row'] ?? ''} • ${order.seatInfo['seat'] ?? ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      child: const Text('VIEW DETAILS'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // TODO: Implement status update dialog
                        onStatusUpdated?.call();
                      },
                      child: const Text('UPDATE STATUS'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status, ThemeData theme) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatStatus(OrderStatus status) {
    return status.toString().split('.').last.replaceAll('_', ' ');
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double amount) {
    return '₪${amount.toStringAsFixed(2)}';
  }
}
