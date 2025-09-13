import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/order_status.dart';
import '../../../services/firebase_service.dart';
import '../../../services/delivery_assignment_service.dart';

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
      title: Text(Translate.get('update_order_status_title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Translate.get('select_new_status_prompt')),
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
                status.toTranslatedString().toUpperCase(),
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
                          title: Text(Translate.get('confirm_status_update_title')),
                          content: Text(Translate.get('confirm_status_update_prompt')
                              .replaceAll('{status}', status.toTranslatedString().toUpperCase())),

                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(Translate.get('cancel').toUpperCase()),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(Translate.get('confirm_button').toUpperCase()),
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
                            // If status set to delivering, auto-assign nearest delivery user
                            if (status == OrderStatus.delivering) {
                              // Use INSTANT device location for assignment (as requested)
                              final String? assignedUserId = await DeliveryAssignmentService
                                  .assignNearestDeliveryUserFromCurrentLocation(orderId: orderId);

                              if (context.mounted) {
                                if (assignedUserId != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${Translate.get('order_status_updated_to').replaceAll('{status}', status.toTranslatedString())} • Assigned: $assignedUserId',
                                      ),
                                      backgroundColor: theme.colorScheme.primary,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Unable to assign delivery automatically. Enable location or add a driver manually.'),
                                      action: SnackBarAction(
                                        label: 'Settings',
                                        onPressed: () {
                                          Geolocator.openAppSettings();
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(Translate.get('order_status_updated_to')
                                      .replaceAll('{status}', status.toTranslatedString())),

                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(Translate.get('failed_to_update_order_status')),
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
          child: Text(Translate.get('close_button').toUpperCase()),
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
