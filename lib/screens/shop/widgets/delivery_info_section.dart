import 'package:flutter/material.dart';

class DeliveryInfoSection extends StatelessWidget {
  final Map<String, dynamic> seatInfo;
  final num subtotal;

  const DeliveryInfoSection({
    Key? key,
    required this.seatInfo,
    required this.subtotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (seatInfo.isEmpty) return const SizedBox();

    final items = [
      {'label': 'Section', 'value': seatInfo['section'], 'icon': Icons.grid_view},
      {'label': 'Row', 'value': seatInfo['row'], 'icon': Icons.table_rows},
      {'label': 'Seat', 'value': seatInfo['seatNo'], 'icon': Icons.event_seat_outlined},
      {'label': 'Roof', 'value': seatInfo['roofNo'], 'icon': Icons.roofing_outlined},
      {'label': 'Subtotal', 'value': subtotal.toString(), 'icon': Icons.attach_money},
     
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_seat, size: 18),
            const SizedBox(width: 6),
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i += 2)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoBox(context, items[i]['label']!, items[i]['value'], items[i]['icon'] as IconData),
                    ),
                    if (i + 1 < items.length) const SizedBox(width: 12),
                    if (i + 1 < items.length)
                      Expanded(
                        child: _infoBox(context, items[i + 1]['label']!, items[i + 1]['value'], items[i + 1]['icon'] as IconData),
                      ),
                  ],
                ),
              if ((seatInfo['seatDetails'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      Text(
                        'Seat Details:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        seatInfo['seatDetails'],
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox(BuildContext context, String label, dynamic value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value?.toString() ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}