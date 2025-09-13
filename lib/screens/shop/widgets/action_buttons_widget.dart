import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import '../../../models/shop_model.dart';

class ActionButtons extends StatelessWidget {
  final ShopModel shop;
  final bool isUpdating;
  final void Function()? onViewOrdersPressed;
  final Future<void> Function()? onUpdateLocationPressed;

  const ActionButtons({
    super.key,
    required this.shop,
    required this.isUpdating,
    required this.onViewOrdersPressed,
    required this.onUpdateLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // View Orders Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isUpdating ? null : onViewOrdersPressed ?? () {},
            icon: const Icon(Icons.receipt_long),
            label: Text(Translate.get('viewOrders')),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Update Location Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isUpdating ? null : onUpdateLocationPressed ?? () async {},
            icon: isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined),
            label: Text(isUpdating ? Translate.get('updating') : Translate.get('updateLocation')),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary, width: 1.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
