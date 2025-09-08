import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/shop_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../orders/orders_list_screen.dart';
import 'widgets/shop_header_widget.dart';
import 'widgets/location_info_card.dart';
import 'widgets/stadium_info_card.dart';
import 'widgets/action_buttons_widget.dart';

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  bool _isUpdatingLocation = false;

  Future<void> _updateLocation() async {
    try {
      // Request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(Translate.get('location_services_disabled'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(Translate.get('location_permissions_denied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(Translate.get('location_permissions_denied_forever'));
      }

      setState(() {
        _isUpdatingLocation = true;
      });

      // Get current location
      final position = await Geolocator.getCurrentPosition();

      // Update shop location in Firestore
      final success = await FirebaseService.updateShopLocation(
        shopId: widget.shop.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (success && mounted) {
        // Create an updated shop object with the new location
        final updatedShop = widget.shop.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          updatedAt: DateTime.now(),
        );

        // Update the shop in the auth provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateShop(updatedShop);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${Translate.get('location_updated_to')} ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (!success) {
        throw Exception(Translate.get('failed_to_update_location'));
      }
    } catch (e) {
      String errorMessage = Translate.get('error_updating_location');
      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shop = widget.shop;

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Header
            ShopHeader(shop: shop),

            // Location Info Card
            LocationInfoCard(
              shop: shop,
              isUpdating: _isUpdatingLocation,
            ),

            const SizedBox(height: 16),

            // Stadium Info Card
            StadiumInfoCard(shop: shop),

            const SizedBox(height: 24),

            // Timestamps
            Text(
              Translate.get('timestamps'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Translate.get('created')}: ${DateFormat('MMM d, y - h:mm a').format(shop.createdAt)}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${Translate.get('last_updated')}: ${DateFormat('MMM d, y - h:mm a').format(shop.updatedAt)}',
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 32),

            // Action Buttons
            ActionButtons(
              shop: shop,
              isUpdating: _isUpdatingLocation,
              onViewOrdersPressed: _isUpdatingLocation
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdersListScreen(shop: shop),
                        ),
                      );
                    },
              onUpdateLocationPressed:
                  _isUpdatingLocation ? null : _updateLocation,
            ),
          ],
        ),
      ),
    );
  }
}
