import 'package:fans_food_order/models/order.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  Future<void> printReceipt(OrderModel order) async {
    final doc = pw.Document();

    // Load a font that supports generic text (optional adjustments might be needed for specific languages)
    // For now we rely on the default printing package fonts or load a standard one if needed.
    // However, 'pdf' package default font usually works for English.
    // For Hebrew/Arabic you might need to load a specific TTF.

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate =
        order.createdAt != null
            ? dateFormatter.format(order.createdAt!.toDate())
            : '';

    doc.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat.roll80, // 80mm roll width. Use roll57 for 58mm.
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Fan Munch',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Order #${order.orderId}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text(formattedDate)),
              pw.Divider(),

              // Customer Info
              if (order.userInfo['userName'] != null)
                pw.Text('Customer: ${order.userInfo['userName']}'),
              if (order.userInfo['userPhoneNo'] != null)
                pw.Text('Phone: ${order.userInfo['userPhoneNo']}'),
              pw.Divider(),

              // Delivery Details
              pw.Text(
                'Delivery Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 3),
              _buildDeliveryInfo(order),
              pw.Divider(),

              // Items
              pw.Text(
                'Items:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              ...order.cart.map((item) {
                final selectedOptions =
                    item.selectedOptions.isNotEmpty
                        ? item.selectedOptions
                            .map((o) => ' - ${o['name']}')
                            .join('\n')
                        : '';

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${item.quantity}x ${item.nameFor('en')}'),
                    if (selectedOptions.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text(
                          selectedOptions,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 5),
                  ],
                );
              }),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for ordering!',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_${order.orderId}',
    );
  }

  pw.Widget _buildDeliveryInfo(OrderModel order) {
    // Check if it's pickup
    if (order.pickupPointId != null && order.pickupPointId!.isNotEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Type: Pickup'),
          pw.Text('Pickup Point ID: ${order.pickupPointId}'),
        ],
      );
    }

    // Check delivery type
    if (order.deliveryType.isNotEmpty) {
      if (order.deliveryType == 'inside') {
        // Inside delivery - match detail page logic
        final locationData =
            order.insideDelivery?['location'] is Map
                ? order.insideDelivery!['location'] as Map<String, dynamic>
                : null;

        final locationName = locationData?['name']?.toString() ?? '';
        final description = locationData?['description']?.toString() ?? '';
        final notes = order.insideDelivery?['notes']?.toString() ?? '';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Type: Inside Delivery'),
            if (locationName.isNotEmpty)
              pw.Text('Location Name: $locationName'),
            if (description.isNotEmpty) pw.Text('Description: $description'),
            if (notes.isNotEmpty) pw.Text('Notes: $notes'),
          ],
        );
      } else if (order.deliveryType == 'outside') {
        // Outside delivery - match detail page logic
        final locationData =
            order.outsideDelivery?['location'] is Map
                ? order.outsideDelivery!['location'] as Map<String, dynamic>
                : null;

        final locationName = locationData?['name']?.toString() ?? '';
        final description = locationData?['description']?.toString() ?? '';
        final notes = order.outsideDelivery?['notes']?.toString() ?? '';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Type: Outside Delivery'),
            if (locationName.isNotEmpty)
              pw.Text('Location Name: $locationName'),
            if (description.isNotEmpty) pw.Text('Description: $description'),
            if (notes.isNotEmpty) pw.Text('Notes: $notes'),
          ],
        );
      }
    }

    // Fallback to old delivery method if available
    if (order.deliveryMethod != null && order.deliveryMethod!.isNotEmpty) {
      return pw.Text('Type: ${order.deliveryMethod}');
    }

    // Default
    return pw.Text('Type: Standard Delivery');
  }
}
