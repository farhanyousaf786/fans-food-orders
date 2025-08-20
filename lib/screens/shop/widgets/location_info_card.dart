import 'package:flutter/material.dart';
import '../../../models/shop_model.dart';

class LocationInfoCard extends StatelessWidget {
  final ShopModel shop;
  final bool isUpdating;

  const LocationInfoCard({
    super.key,
    required this.shop,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Location',
              '${shop.location} (${shop.floor} Floor, ${shop.gate} Gate)',
              theme,
            ),
            if (shop.latitude != null && shop.longitude != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.my_location,
                'Coordinates',
                '${shop.latitude!.toStringAsFixed(6)}, ${shop.longitude!.toStringAsFixed(6)}',
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
