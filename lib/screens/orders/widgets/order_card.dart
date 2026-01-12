
import 'package:fans_food_order/translations/translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fans_food_order/screens/orders/widgets/status_update_dialog.dart';
import 'package:flutter/material.dart';



import '../../../models/order.dart';
import '../../../models/order_status.dart';
import '../../../widgets/app_colors.dart';
import '../screens/order_details_screen.dart';
import '../../../utils/currency_helper.dart';

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
      color: Colors.white,
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
                    '${Translate.get('order_id_prefix')}${order.orderId}',
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
                      order.status.toTranslatedString().toUpperCase(),
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
                '${Translate.get('items_count').replaceAll('{count}', order.cart.length.toString())} • ${_formatPrice(order.total,order.cart.first.currency)}',
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
                        '${order.seatInfo['section'] ?? Translate.get('section')} ${order.seatInfo['row'] ?? ''} • ${order.seatInfo['seatNo'] ?? ''}'
                        '${order.seatInfo['floor'] != null ? ' • ${Translate.get('floor')}: ${order.seatInfo['floor']}' : ''}'
                        '${order.seatInfo['room'] != null ? ' • ${Translate.get('room')}: ${order.seatInfo['room']}' : ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child:
                    ElevatedButton.icon(
                      onPressed:  () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: Text(Translate.get('view_details')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1.5,
                      ),
                    ),



                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primaryColor, // <-- change to your desired color
                          width: 2,           // optional, default is 1
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // optional rounded corners
                        ),
                      ),
                      onPressed: () async {
                        await showStatusUpdateDialog(
                          context: context,
                          orderModel: order,
                          currentStatus: order.status.index,
                          onStatusUpdated: (int newStatus) {
                            onStatusUpdated?.call();
                          },
                        );
                      },
                      child: Text(Translate.get('update_status'),style: TextStyle(color: AppColors.primaryColor),),
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


  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return Translate.get('dateNotAvailable');
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double amount, String currency) {
    return '${CurrencyHelper.getSymbol(currency)}${amount.toStringAsFixed(2)}';
  }
}
