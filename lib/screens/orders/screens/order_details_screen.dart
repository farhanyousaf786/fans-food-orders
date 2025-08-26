import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Section

            const SizedBox(height: 20),

            // Order Status Section
            Text(
              'Status',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildStatusIndicator(order.status, theme),
            const SizedBox(height: 20),

            // Order Items Section
            Text(
              'Items',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.cart.length,
              itemBuilder: (context, index) {
                final item = order.cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: item.images.isNotEmpty
                        ? Image.network(
                            item.images[0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.fastfood,
                                color: Colors.grey[400]),
                          ),
                    title: Text(item.name),
                    subtitle: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₪${item.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text('Qty: ${item.quantity}'),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Order Summary Section
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow('Subtotal', '₪${order.subtotal.toStringAsFixed(2)}'),
                    if (order.tipAmount > 0)
                      _buildSummaryRow('Tip', '₪${order.tipAmount.toStringAsFixed(2)}'),
                    if (order.deliveryFee > 0)
                      _buildSummaryRow('Handling & Delivery', '₪${order.deliveryFee.toStringAsFixed(2)}'),
                    _buildSummaryRow('Total', '₪${order.total.toStringAsFixed(2)}',
                        isTotal: true),
                  ],
                ),
              ),
            ),

            // Seat Information
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Information',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDeliveryInfoRow(Icons.area_chart, 'Area', order.seatInfo['area'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.door_front_door, 'Entrance', order.seatInfo['entrance'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.view_stream, 'Row', order.seatInfo['row'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.event_seat, 'Seat No.', order.seatInfo['seatNo'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.details, 'Seat Details', order.seatInfo['seatDetails'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.grid_view, 'Section', order.seatInfo['section'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.stadium, 'Stand', order.seatInfo['stand'] ?? '-'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(OrderStatus status, ThemeData theme) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            status.toString().split('.').last.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
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
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
