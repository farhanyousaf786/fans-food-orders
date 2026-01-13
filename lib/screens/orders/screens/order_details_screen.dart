import 'package:fans_food_order/screens/orders/screens/qr_scan_screen.dart';
import 'package:fans_food_order/translations/translate.dart';
import 'package:fans_food_order/widgets/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../models/order.dart';

import '../../../models/order_status.dart';
import '../../../services/firebase_service.dart';
import '../../../translations/language_service.dart';
import '../../../utils/currency_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/custom_text_style.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.getCurrentLanguage();
    final theme = Theme.of(context);

    debugPrint('--- Order Details Debug ---');
    debugPrint('Order ID: ${order.orderId}');
    debugPrint('Delivery Method: ${order.deliveryMethod}');
    debugPrint('Pickup Point ID: ${order.pickupPointId}');
    debugPrint('Stadium ID: ${order.stadiumId}');
    debugPrint('---------------------------');

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text('${Translate.get('order')} #${order.orderId}'),
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
            // ... (keep QR, status, items, summary, customer info) ...
            const SizedBox(height: 20),

            // Order Status Section
            Text(Translate.get('status'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildStatusIndicator(order.status, theme),
            const SizedBox(height: 20),

            // Order Items Section
            Text(Translate.get('items'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.cart.length,
              itemBuilder: (context, index) {
                final item = order.cart[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading:
                        item.images.isNotEmpty
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
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey[400],
                              ),
                            ),
                    title: Text(item.nameFor(lang)),
                    subtitle: Text(
                      item.descriptionFor(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${CurrencyHelper.getSymbol(item.currency)}${item.price.toStringAsFixed(2)}',
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
              color: Colors.white,
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
                      Translate.get('subtotal'),
                      '${CurrencyHelper.getSymbol(order.cart.first.currency)}${order.subtotal.toStringAsFixed(2)}',
                    ),
                    if (order.tipAmount > 0)
                      _buildSummaryRow(
                        Translate.get('tip'),
                        '${CurrencyHelper.getSymbol(order.cart.first.currency)}${order.tipAmount.toStringAsFixed(2)}',
                      ),
                    if (order.deliveryFee > 0)
                      _buildSummaryRow(
                        Translate.get('handlingAndDelivery'),
                        '${CurrencyHelper.getSymbol(order.cart.first.currency)}${order.deliveryFee.toStringAsFixed(2)}',
                      ),
                    _buildSummaryRow(
                      Translate.get('total'),
                      '${CurrencyHelper.getSymbol(order.cart.first.currency)}${order.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // Customer Information Section
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
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

            // Seat Information OR Pickup Information
            const SizedBox(height: 20),
            if (order.deliveryMethod == 'pickup' && order.pickupPointId != null)
<<<<<<< Updated upstream
              Column(
                children: [
                  _buildPickupDetails(
                    order.stadiumId,
                    order.pickupPointId!,
                    theme,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (order.status == OrderStatus.delivered) {
                          return;
                        }

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRScanScreen(),
                          ),
                        );

                        if (result != null && context.mounted) {
                          if (result == order.orderCode) {
                            await FirebaseService.updateOrderStatus(
                              orderId: order.id,
                              newStatus: OrderStatus.delivered.index,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Translate.get('invalid_order_code'),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                        //  _showCompleteOrderBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      label: Text(
                        Translate.get('complete_delivery'),
                        style: CustomTextStyle.size16Weight600Text().copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
=======
              _buildPickupDetails(order.stadiumId, order.pickupPointId!, theme)
>>>>>>> Stashed changes
            else if (order.deliveryType == 'inside' &&
                order.insideDelivery != null)
              _buildExtendedDeliveryDetails(
                Translate.get('inside_delivery'),
                order.insideDelivery!,
                theme,
              )
            else if (order.deliveryType == 'outside' &&
                order.outsideDelivery != null)
              _buildExtendedDeliveryDetails(
                Translate.get('outside_delivery'),
                order.outsideDelivery!,
                theme,
              )
            else
              Card(
                color: Colors.white,
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
                          // Row
                          if (order.seatInfo['row'] != null &&
                              order.seatInfo['row'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.view_stream,
                              Translate.get('row'),
                              order.seatInfo['row'].toString(),
                            ),
                          ],

                          // Seat No
                          if (order.seatInfo['seatNo'] != null &&
                              order.seatInfo['seatNo']
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.event_seat,
                              Translate.get('seat_no'),
                              order.seatInfo['seatNo'].toString(),
                            ),
                          ],

                          // Section
                          if (order.seatInfo['section'] != null &&
                              order.seatInfo['section']
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.grid_view,
                              Translate.get('section'),
                              order.seatInfo['section'].toString(),
                            ),
                          ],

                          // Stand
                          if (order.seatInfo['stand'] != null &&
                              order.seatInfo['stand']
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.stadium,
                              Translate.get('stand'),
                              order.seatInfo['stand'].toString(),
                            ),
                          ],

                          // Floor
                          if (order.seatInfo['floor'] != null &&
                              order.seatInfo['floor']
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.layers,
                              Translate.get('floor'),
                              order.seatInfo['floor'].toString(),
                            ),
                          ],

                          // Room
                          if (order.seatInfo['room'] != null &&
                              order.seatInfo['room'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDeliveryInfoRow(
                              Icons.meeting_room,
                              Translate.get('room'),
                              order.seatInfo['room'].toString(),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Ticket Image Section
            if (order.seatInfo['ticketImage'] != null &&
                order.seatInfo['ticketImage'].toString().isNotEmpty)
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
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                order.seatInfo['ticketImage'],
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: theme.colorScheme.error,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Failed to load ticket image',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.error,
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

  Widget _buildPickupDetails(
    String stadiumId,
    String pickupPointId,
    ThemeData theme,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('stadiums')
              .doc(stadiumId)
              .collection('pickUpPoints')
              .doc(pickupPointId)
              .get(),
      builder: (context, snapshot) {
        debugPrint('--- Pickup Point FutureBuilder ---');
        debugPrint('Connection State: ${snapshot.connectionState}');
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          debugPrint('Document DOES NOT exist or No Data');
          debugPrint(
            'Path queried: stadiums/$stadiumId/pickupPoints/$pickupPointId',
          );
          return const SizedBox();
        }

        debugPrint('Document FOUND!');
        final data = snapshot.data!.data() as Map<String, dynamic>;
        debugPrint('Data: $data');

        final name = data['name'] ?? '';
        final location = data['location'] ?? '';
        final description = data['description'] ?? '';

        return Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translate.get('pickupDetails'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryInfoRow(Icons.store, 'Name', name),
                    const SizedBox(height: 12),
                    _buildDeliveryInfoRow(
                      Icons.location_on,
                      Translate.get('pickupLocation'),
                      location,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDeliveryInfoRow(
                        Icons.info_outline,
                        Translate.get('pickupInstructions'),
                        description,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(OrderStatus status, ThemeData theme) {
    final statusColor = _getStatusColor(status);
    final statusText =
        (order.deliveryMethod == 'pickup' && status == OrderStatus.delivering)
            ? Translate.get('readyToPickup')
            : order.status.toTranslatedString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
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
            children: [Text(label), Text(value)],
          ),
        ),
      ],
    );
  }

  Widget _buildExtendedDeliveryDetails(
    String title,
    Map<String, dynamic> deliveryData,
    ThemeData theme,
  ) {
    final locationData = deliveryData['location'] as Map<String, dynamic>?;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (locationData != null && locationData['name'] != null)
                  _buildDeliveryInfoRow(
                    Icons.location_on,
                    'Location Name',
                    locationData['name'].toString(),
                  ),
                if (locationData != null && locationData['description'] != null)
                  _buildDeliveryInfoRow(
                    Icons.description,
                    'Description',
                    locationData['description'].toString(),
                  ),
                if (deliveryData['notes'] != null &&
                    deliveryData['notes'].toString().isNotEmpty)
                  _buildDeliveryInfoRow(
                    Icons.note,
                    'Notes',
                    deliveryData['notes'].toString(),
                  ),
                if (deliveryData['fee'] != null)
                  _buildDeliveryInfoRow(
                    Icons.attach_money,
                    'Extra Fee',
                    '${deliveryData['currency'] ?? ''} ${deliveryData['fee']}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
