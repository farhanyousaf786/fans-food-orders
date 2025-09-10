import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import '../../../models/order.dart';

import '../../../models/order_status.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${Translate.get('order')} #${order.id}'),
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
              Translate.get('status'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildStatusIndicator(order.status, theme),
            const SizedBox(height: 20),

            // Order Items Section
            Text(
              Translate.get('items'),
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
                        Text('${Translate.get('quantity')}: ${item.quantity}'),
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
                      Translate.get('order_summary'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                        Translate.get('subtotal'), '₪${order.subtotal.toStringAsFixed(2)}'),
                    if (order.tipAmount > 0)
                      _buildSummaryRow(Translate.get('tip'), '₪${order.tipAmount.toStringAsFixed(2)}'),
                    if (order.deliveryFee > 0)
                      _buildSummaryRow(Translate.get('handlingAndDelivery'), '₪${order.deliveryFee.toStringAsFixed(2)}'),
                    _buildSummaryRow(Translate.get('total'), '₪${order.total.toStringAsFixed(2)}',
                        isTotal: true),
                  ],
                ),
              ),
            ),

            // Customer Information Section
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translate.get('customer_information'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDeliveryInfoRow(
                          Icons.person,
                          Translate.get('name'),
                          (order.userInfo['userName'] ?? '-').toString(),
                        ),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(
                          Icons.phone,
                          Translate.get('phone'),
                          (order.userInfo['userPhoneNo'] ?? '-').toString(),
                        ),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(
                          Icons.email,
                          Translate.get('email'),
                          (order.userInfo['userEmail'] ?? '-').toString(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
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
                      Translate.get('delivery_information'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDeliveryInfoRow(Icons.area_chart, Translate.get('area'),
                            order.seatInfo['area'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.door_front_door,
                            Translate.get('entrance'), order.seatInfo['entrance'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.view_stream, Translate.get('row'),
                            order.seatInfo['row'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.event_seat, Translate.get('seat_no'),
                            order.seatInfo['seatNo'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.details, Translate.get('seat_details'),
                            order.seatInfo['seatDetails'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.grid_view, Translate.get('section'),
                            order.seatInfo['section'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildDeliveryInfoRow(Icons.stadium, Translate.get('stand'),
                            order.seatInfo['stand'] ?? '-'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Ticket Image Section
            if (order.seatInfo['ticketImage'] != null && order.seatInfo['ticketImage'].toString().isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ticket Image',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                order.seatInfo['ticketImage'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: theme.colorScheme.errorContainer,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: theme.colorScheme.error,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Failed to load ticket image',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
            order.status.toTranslatedString(),
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
