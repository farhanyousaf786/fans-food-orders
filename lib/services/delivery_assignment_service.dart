import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_food_order/models/order_status.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class DeliveryAssignmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Finds the nearest active delivery user and assigns them to the order
  static Future<String?> assignNearestDeliveryUser({
    required String orderId,
    required double orderLatitude,
    required double orderLongitude,
  }) async {
    try {
      debugPrint('🔍 SEARCHING for nearest delivery user...');
      debugPrint(
        '📍 Order location: Lat ${orderLatitude.toStringAsFixed(6)}, Lng ${orderLongitude.toStringAsFixed(6)}',
      );

      // Get all active delivery users
      final deliveryUsersSnapshot =
          await _firestore
              .collection('deliveryUsers')
              .where('isActive', isEqualTo: true)
              .get();

      debugPrint(
        '👥 Found ${deliveryUsersSnapshot.docs.length} active delivery users',
      );

      if (deliveryUsersSnapshot.docs.isEmpty) {
        debugPrint('❌ No active delivery users found');
        return null;
      }

      String? nearestUserId;
      double shortestDistance = double.infinity;

      // Calculate distance for each active delivery user
      for (var doc in deliveryUsersSnapshot.docs) {
        final data = doc.data();
        final location = data['location'] as GeoPoint?;

        if (location != null) {
          // Calculate distance using Haversine formula
          final distance = Geolocator.distanceBetween(
            orderLatitude,
            orderLongitude,
            location.latitude,
            location.longitude,
          );

          final distanceInKm = distance / 1000;
          debugPrint(
            'User ${doc.id}: Distance = ${distance.toStringAsFixed(2)}m (${distanceInKm.toStringAsFixed(2)}km)',
          );

          if (distance < shortestDistance) {
            shortestDistance = distance;
            nearestUserId = doc.id;
          }
        }
      }

      if (nearestUserId != null) {
        // Update the order with the nearest delivery user ID
        await _firestore.collection('orders').doc(orderId).update({
          'deliveryUserId': nearestUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final shortestDistanceInKm = shortestDistance / 1000;
        debugPrint(
          '✅ ASSIGNED: Delivery user $nearestUserId to order $orderId',
        );
        debugPrint(
          '📍 Distance: ${shortestDistance.toStringAsFixed(2)}m (${shortestDistanceInKm.toStringAsFixed(2)}km)',
        );
        return nearestUserId;
      }

      return null;
    } catch (e) {
      debugPrint('Error assigning delivery user: $e');
      return null;
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static Future<String?> getNearestDeliveryUser({
    required String orderId,
    required double orderLatitude,
    required double orderLongitude,
  }) async {
    try {


      debugPrint(
        '📍 Order location: Lat ${orderLatitude.toStringAsFixed(6)}, Lng ${orderLongitude.toStringAsFixed(6)}',
      );
      final deliveryUsers =
          await FirebaseFirestore.instance
              .collection('deliveryUsers')
              .where('isActive', isEqualTo: true)
              .get();

      if (deliveryUsers.docs.isEmpty) return null;

      var nearestUserId = '';
      var minDistance = double.infinity;

      for (var doc in deliveryUsers.docs) {
        final userData = doc.data();
        if (userData['location'] == null) continue;

        final GeoPoint location = userData['location'];

        final distance = calculateDistance(
          orderLatitude,
          orderLongitude,
          location.latitude,
          location.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestUserId = doc.id;
        }
      }

      // Update the order with the nearest delivery user ID
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryUserId': nearestUserId,
        'status': OrderStatus.delivering.index,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final shortestDistanceInKm = minDistance / 1000;
      debugPrint(
        '✅ ASSIGNED: Delivery user $nearestUserId to order $orderId',
      );
      debugPrint(
        '📍 Distance: ${minDistance.toStringAsFixed(2)}m (${shortestDistanceInKm.toStringAsFixed(2)}km)',
      );
      return nearestUserId.isEmpty ? null : nearestUserId;



    } catch (e) {
      debugPrint('Error assigning delivery user: $e');
      return null;
    }
  }

  /// Gets the current location and assigns nearest delivery user
  static Future<String?> assignNearestDeliveryUserFromCurrentLocation({
    required String orderId,
  }) async {
    try {
      // Ensure location services enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check/request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied by user');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permission denied forever. Ask user to enable in settings.',
        );
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


      return await getNearestDeliveryUser(
        orderId: orderId,
        orderLatitude: position.latitude,
        orderLongitude: position.longitude,
      );


    } catch (e) {
      debugPrint('Error getting current location for delivery assignment: $e');
      return null;
    }
  }

  /// Gets delivery user information by ID
  static Future<Map<String, dynamic>?> getDeliveryUserInfo(
    String userId,
  ) async {
    try {
      final doc =
          await _firestore.collection('deliveryUsers').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting delivery user info: $e');
      return null;
    }
  }

  /// Assign using the order's saved location (order.location or order.customerLocation)
  static Future<String?> assignNearestDeliveryUserUsingOrderLocation({
    required String orderId,
  }) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        debugPrint('Order $orderId not found');
        return null;
      }
      final data = doc.data()!;
      GeoPoint? geo = data['location'] as GeoPoint?;
      geo ??= data['customerLocation'] as GeoPoint?;
      if (geo == null) {
        debugPrint('Order has no saved location');
        return null;
      }
      return assignNearestDeliveryUser(
        orderId: orderId,
        orderLatitude: geo.latitude,
        orderLongitude: geo.longitude,
      );
    } catch (e) {
      debugPrint('Error assigning using order location: $e');
      return null;
    }
  }
}
