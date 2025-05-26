import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/stadium_model.dart';
import '../../models/shop_model.dart';
import '../../providers/auth_provider.dart';
import '../shop/shop_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final isShopOwner = user?.role == 'shopowner';

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? "User"}\'s Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            },
          ),
        ],
      ),
      body: !isShopOwner
          ? const Center(
              child: Text('Only shop owners can access this area'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('stadiums').snapshots(),
              builder: (context, stadiumSnapshot) {
                if (stadiumSnapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (stadiumSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stadiums = stadiumSnapshot.data?.docs
                    .map((doc) => StadiumModel.fromFirestore(doc))
                    .toList() ??
                    [];

                if (stadiums.isEmpty) {
                  return const Center(child: Text('No stadiums found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stadiums.length,
                  itemBuilder: (context, index) {
                    final stadium = stadiums[index];
                    return StadiumCard(
                      stadium: stadium,
                      userId: user?.id ?? '',
                    );
                  },
                );
              },
            ),
    );
  }
}

class StadiumCard extends StatelessWidget {
  final StadiumModel stadium;
  final String userId;

  const StadiumCard({
    super.key,
    required this.stadium,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stadium.imageUrl.isNotEmpty)
            Image.network(
              stadium.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stadium.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  stadium.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Shops in this Stadium:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stadiums')
                      .doc(stadium.id)
                      .collection('shops')
                      .where('admins', arrayContains: userId)
                      .snapshots(),
                  builder: (context, shopSnapshot) {
                    if (shopSnapshot.hasError) {
                      return const Text('Error loading shops');
                    }

                    if (shopSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final shops = shopSnapshot.data?.docs
                        .map((doc) => ShopModel.fromFirestore(doc))
                        .toList() ??
                        [];

                    if (shops.isEmpty) {
                      return const Text('No shops found in this stadium');
                    }

                    return Column(
                      children: shops.map((shop) => ShopTile(shop: shop)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShopTile extends StatelessWidget {
  final ShopModel shop;

  const ShopTile({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(shop.name),
      subtitle: Text('${shop.location} - Floor ${shop.floor}, Gate ${shop.gate}'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailsScreen(shop: shop),
          ),
        );
      },
    );
  }
}
