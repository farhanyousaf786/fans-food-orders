import 'package:fans_food_order/providers/language_provider.dart';
import 'package:fans_food_order/translations/app_translations.dart';
import 'package:fans_food_order/translations/translate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../../models/shop_model.dart';
import '../shop/shop_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(Translate.get('loading_shops'),
                  style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    // If not authenticated, redirect to sign in
    if (!authProvider.isAuthenticated) {
      return const SignInScreen();
    }

    // Show shops list for shop owners
    return Scaffold(
      appBar: AppBar(
        title: Text(Translate.get('my_shops')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => authProvider.loadUserData(),
            tooltip: Translate.get('refresh'),
          ),
          _buildLanguageSwitcher(context),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, authProvider),
            tooltip: Translate.get('sign_out'),
          ),
        ],
      ),
      body: authProvider.userShops.isEmpty
          ? _buildEmptyState(theme, context)
          : _buildShopsList(authProvider.userShops, theme),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return PopupMenuButton<String>(
      onSelected: (String languageCode) {
        languageProvider.changeLanguage(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) {
        return AppTranslations.languageNames.keys.map((String code) {
          return PopupMenuItem<String>(
            value: code,
            child: Text(AppTranslations.languageNames[code]!),
          );
        }).toList();
      },
      icon: const Icon(Icons.language),
      tooltip: Translate.get('language'),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            Translate.get('no_shops_found'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.get('no_shops_assigned'),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShopsList(List<ShopModel> shops, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        return _buildShopCard(shop, theme, context);
      },
    );
  }

  Widget _buildShopCard(ShopModel shop, ThemeData theme, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailScreen(shop: shop),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.store,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.location_on, shop.location, theme),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      Icons.stairs,
                      '${Translate.get('floor')}: ${shop.floor}',
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailRow(
                      Icons.door_front_door,
                      '${Translate.get('gate')}: ${shop.gate}',
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${Translate.get('updated')}: ${DateFormat('MMM d, y • h:mm a').format(shop.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translate.get('sign_out')),
        content: Text(Translate.get('sign_out_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translate.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            child: Text(
              Translate.get('sign_out'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
