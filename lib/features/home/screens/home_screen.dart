import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/crops/screens/crops_screen.dart';
import 'package:agricola/features/home/screens/agri_shop_dashboard_screen.dart';
import 'package:agricola/features/home/screens/farmer_dashboard_screen.dart';
import 'package:agricola/features/home/screens/merchant_dashboard_screen.dart';
import 'package:agricola/features/inventory/screens/farmer_inventory_screen.dart';
import 'package:agricola/features/inventory/screens/merchant_inventory_screen.dart';
import 'package:agricola/features/marketplace/screens/marketplace_screen.dart';
import 'package:agricola/features/orders/screens/agri_shop_orders_screen.dart';
import 'package:agricola/features/profile/screens/profile_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart'
    show UserType;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final authState = ref.watch(unifiedAuthStateProvider);
    final user = authState.user;
    final isAnonymous = user?.isAnonymous ?? true;

    if (isAnonymous) {
      return _buildAnonymousHomeScreen(context, currentLang);
    }

    // Use actual user data from Firebase/Firestore, NOT the cached profileSetupProvider
    // This ensures the correct dashboard is shown based on the logged-in user's type
    final isFarmer = user?.userType == UserType.farmer;
    final isAgriShop = user?.merchantType == MerchantType.agriShop;

    final List<Widget> widgetOptions = isFarmer
        ? [
            const FarmerDashboardScreen(),
            const MarketplaceScreen(),
            const CropsScreen(),
            const FarmerInventoryScreen(),
            const ProfileScreen(),
          ]
        : (isAgriShop
              ? [
                  const AgriShopDashboardScreen(),
                  const MerchantInventoryScreen(),
                  const AgriShopOrdersScreen(),
                  const MarketplaceScreen(),
                  const ProfileScreen(),
                ]
              : [
                  const MerchantDashboardScreen(),
                  const MarketplaceScreen(),
                  const MerchantInventoryScreen(),
                  const ProfileScreen(),
                ]);

    // Ensure selected index is within bounds
    if (_selectedIndex >= widgetOptions.length) {
      _selectedIndex = 0;
    }

    final List<BottomNavigationBarItem> navItems = isFarmer
        ? [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: t('dashboard', currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
              label: t('marketplace', currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grass_outlined),
              activeIcon: const Icon(Icons.grass),
              label: t('crops', currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: t('inventory', currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_outlined),
              activeIcon: const Icon(Icons.person),
              label: t('profile', currentLang),
            ),
          ]
        : (isAgriShop
              ? [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: t('dashboard', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.inventory_2_outlined),
                    activeIcon: const Icon(Icons.inventory_2),
                    label: t('products', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.receipt_long_outlined),
                    activeIcon: const Icon(Icons.receipt_long),
                    label: t('orders', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.store_outlined),
                    activeIcon: const Icon(Icons.store),
                    label: t('marketplace', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_outlined),
                    activeIcon: const Icon(Icons.person),
                    label: t('profile', currentLang),
                  ),
                ]
              : [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: t('dashboard', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.store_outlined),
                    activeIcon: const Icon(Icons.store),
                    label: t('marketplace', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.inventory_2_outlined),
                    activeIcon: const Icon(Icons.inventory_2),
                    label: t('produce', currentLang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_outlined),
                    activeIcon: const Icon(Icons.person),
                    label: t('profile', currentLang),
                  ),
                ]);

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: navItems,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2D6A4F),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAnonymousHomeScreen(BuildContext context, AppLanguage lang) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  size: 80,
                  color: AppColors.green.withAlpha(178),
                ),
                const SizedBox(height: 24),
                Text(
                  t('welcome_to_agricola', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('sign_in_to_access_features', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                AppPrimaryButton(
                  label: t('sign_in', lang),
                  onTap: () => context.go('/sign-in'),
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: t('sign_up', lang),
                  onTap: () => context.go('/register'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/marketplace'),
                  child: Text(
                    t('browse_marketplace', lang),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
