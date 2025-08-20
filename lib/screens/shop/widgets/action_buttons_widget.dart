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
    return Column(
      children: [
        // View Orders Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isUpdating ? null : onViewOrdersPressed ?? () {},
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Orders'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            label: Text(isUpdating ? 'Updating...' : 'Update Location'),
            style: OutlinedButton.styleFrom(
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
