import 'package:flutter/material.dart';
import '../../../models/order_status.dart';
import '../../../services/firebase_service.dart';

class StatusUpdateDialog extends StatelessWidget {
  final String orderId;
  /// The current status index (0: pending, 1: preparing, 2: delivering, 3: delivered)
  final int currentStatus;
  final Function(int) onStatusUpdated;

  const StatusUpdateDialog({
    super.key,
    required this.orderId,
    required this.currentStatus,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = OrderStatus.values
        .where((status) => status != OrderStatus.cancelled)
        .toList();

    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select the new status for this order:'),
          const SizedBox(height: 16),
          ...statuses.map((status) {
            final isCurrent = status.name == currentStatus;
            return ListTile(
              leading: Radio<int>(
                value: status.index,
                groupValue: currentStatus,
                onChanged: null, // Disable radio button selection
              ),
              title: Text(
                status.name.toUpperCase(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isCurrent ? theme.colorScheme.primary : null,
                  fontWeight: isCurrent ? FontWeight.bold : null,
                ),
              ),
              onTap: isCurrent
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Status Update'),
                          content: Text(
                              'Change order status to ${status.name.toUpperCase()}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('CONFIRM'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final success = await FirebaseService.updateOrderStatus(
                          orderId: orderId,
                          newStatus: status.index,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Close the dialog
                          if (success) {
                            onStatusUpdated(status.index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Order status updated to ${status.name}'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to update order status'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}

Future<void> showStatusUpdateDialog({
  required BuildContext context,
  required String orderId,
  required int currentStatus,
  required Function(int) onStatusUpdated,
}) async {
  return showDialog(
    context: context,
    builder: (context) => StatusUpdateDialog(
      orderId: orderId,
      currentStatus: currentStatus,
      onStatusUpdated: onStatusUpdated,
    ),
  );
}
