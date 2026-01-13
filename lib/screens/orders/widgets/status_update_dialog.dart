import 'package:fans_food_order/models/order.dart';
import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/order_status.dart';
import '../../../services/firebase_service.dart';
import '../../../services/delivery_assignment_service.dart';
import '../../../services/notification_class.dart';

class StatusUpdateDialog extends StatelessWidget {
  final OrderModel orderModel;

  /// The current status index (0: pending, 1: preparing, 2: delivering, 3: delivered)
  final int currentStatus;
  final Function(int) onStatusUpdated;

  const StatusUpdateDialog({
    super.key,
    required this.orderModel,
    required this.currentStatus,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses =
        OrderStatus.values
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
            // Fix comparison: compare indices, not names
            final isCurrent = status.index == currentStatus;
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
              onTap:
                  isCurrent
                      ? null
                      : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  Translate.get('confirm_status_update_title'),
                                ),
                                content: Text(
                                  Translate.get(
                                    'confirm_status_update_prompt',
                                  ).replaceAll(
                                    '{status}',
                                    status.toTranslatedString().toUpperCase(),
                                  ),
                                ),

                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      Translate.get('cancel').toUpperCase(),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      Translate.get(
                                        'confirm_button',
                                      ).toUpperCase(),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true) {
                          try {
                            bool updateOk = true;
                            if (status != OrderStatus.delivering) {
                              updateOk =
                                  await FirebaseService.updateOrderStatus(
                                    orderId: orderModel.id,
                                    newStatus: status.index,
                                  );
                            }

                            if (!context.mounted) return;
                            Navigator.pop(context); // Close the dialog

                            if (!updateOk && status != OrderStatus.delivering) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Translate.get(
                                      'failed_to_update_order_status',
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // If status set to delivering
                            if (status == OrderStatus.delivering) {
                              if (orderModel.deliveryMethod == 'pickup') {
                                // PICKUP ORDER: Do NOT assign delivery user
                                try {
                                  await FirebaseService.updateOrderStatus(
                                    orderId: orderModel.id,
                                    newStatus: status.index,
                                  );

                                  if (!context.mounted) return;
                                  onStatusUpdated(status.index);

                                  // Send notification to user
                                  try {
                                    final tokens =
                                        await FirebaseService.getOrderUserFcmTokens(
                                          userId: orderModel.userInfo['userId'],
                                          deliveryUserId:
                                              '', // No delivery user
                                        );
                                    // Fallback to token stored in order's userInfo if available
                                    final userToken =
                                        tokens['userToken'] ??
                                        (orderModel.userInfo['fcmToken']
                                            as String?);

                                    if (userToken != null &&
                                        userToken.isNotEmpty) {
                                      await NotificationServiceClass()
                                          .sendNotification(
                                            userToken,
                                            Translate.get(
                                              'notification_order_update_title',
                                            ),
                                            Translate.get(
                                              'notification_order_update_body',
                                            ).replaceAll(
                                              '{status}',
                                              Translate.get('readyToPickup'),
                                            ),
                                          );
                                    }
                                  } catch (_) {}

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translate.get(
                                          'order_status_updated_to',
                                        ).replaceAll(
                                          '{status}',
                                          Translate.get('readyToPickup'),
                                        ),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translate.get('something_went_wrong'),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // DELIVERY ORDER: Auto-assign nearest delivery user
                                try {
                                  // Use INSTANT device location for assignment (as requested)
                                  final String? assignedUserId =
                                      await DeliveryAssignmentService.assignDeliveryUserByShop(
                                        orderId: orderModel.id,
                                        shopId: orderModel.shopId,
                                      );

                                  if (assignedUserId != null) {
                                    if (!context.mounted) return;
                                    onStatusUpdated(status.index);

                                    // Fetch tokens (user and delivery)
                                    final tokens =
                                        await FirebaseService.getOrderUserFcmTokens(
                                          userId: orderModel.userInfo['userId'],
                                          deliveryUserId: assignedUserId,
                                        );

                                    // Fallback to token stored in order's userInfo if available
                                    tokens['userToken'] =
                                        tokens['userToken'] ??
                                        (orderModel.userInfo['fcmToken']
                                            as String?);

                                    // Send notification to user (try/catch to avoid crash)
                                    try {
                                      final userToken = tokens['userToken'];
                                      if (userToken != null &&
                                          userToken.isNotEmpty) {
                                        await NotificationServiceClass()
                                            .sendNotification(
                                              userToken,
                                              Translate.get(
                                                'notification_order_update_title',
                                              ),
                                              Translate.get(
                                                'notification_order_update_body',
                                              ).replaceAll(
                                                '{status}',
                                                status.toTranslatedString(),
                                              ),
                                            );
                                      }
                                    } catch (_) {}

                                    // Send notification to delivery user (try/catch to avoid crash)
                                    try {
                                      final deliveryToken =
                                          tokens['deliveryUserToken'];
                                      if (deliveryToken != null &&
                                          deliveryToken.isNotEmpty) {
                                        await NotificationServiceClass()
                                            .sendNotification(
                                              deliveryToken,
                                              Translate.get(
                                                'notification_order_assigned_title',
                                              ),
                                              Translate.get(
                                                'notification_order_assigned_body',
                                              ).replaceAll(
                                                '{orderCode}',
                                                orderModel.orderCode,
                                              ),
                                            );
                                      }
                                    } catch (_) {}

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${Translate.get('order_status_updated_to').replaceAll('{status}', status.toTranslatedString())} • ${Translate.get('assigned_to_user').replaceAll('{userId}', assignedUserId)}',
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    );
                                  } else {
                                    // NO DELIVERY PERSON FOUND - SHOW ERROR
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          Translate.get(
                                            'auto_assign_delivery_failed',
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Avoid crash on assignment errors
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translate.get(
                                          'auto_assign_delivery_failed',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              // Non-delivering status success
                              onStatusUpdated(status.index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Translate.get(
                                      'order_status_updated_to',
                                    ).replaceAll(
                                      '{status}',
                                      status.toTranslatedString(),
                                    ),
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Translate.get('something_went_wrong'),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
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
  required OrderModel orderModel,
  required int currentStatus,
  required Function(int) onStatusUpdated,
}) async {
  return showDialog(
    context: context,
    builder:
        (context) => StatusUpdateDialog(
          orderModel: orderModel,
          currentStatus: currentStatus,
          onStatusUpdated: onStatusUpdated,
        ),
  );
}
