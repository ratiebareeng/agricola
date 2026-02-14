import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/crops/screens/crops_screen.dart';
import 'package:agricola/features/home/screens/agri_shop_dashboard_screen.dart';
import 'package:agricola/features/home/screens/farmer_dashboard_screen.dart';
import 'package:agricola/features/home/screens/merchant_dashboard_screen.dart';
import 'package:agricola/features/home/widgets/anonymous_home_screen_content.dart';
import 'package:agricola/features/home/widgets/home_bottom_navigation_bar.dart';
import 'package:agricola/features/inventory/screens/farmer_inventory_screen.dart';
import 'package:agricola/features/inventory/screens/merchant_inventory_screen.dart';
import 'package:agricola/features/marketplace/screens/marketplace_screen.dart';
import 'package:agricola/features/orders/screens/agri_shop_orders_screen.dart';
import 'package:agricola/features/profile/screens/profile_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart'
    show UserType;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final selectedIndex = ref.watch(selectedTabProvider);
    final authState = ref.watch(unifiedAuthStateProvider);
    final user = authState.user;
    final isAnonymous = user?.isAnonymous ?? true;

    if (isAnonymous) {
      return AnonymousHomeScreenContent(lang: currentLang);
    }

    // Use actual user data from Firebase/Firestore, NOT the cached profileSetupProvider
    // This ensures the correct dashboard is shown based on the logged-in user's type
    final isFarmer = user?.userType == UserType.farmer;
    final isAgriShop = user?.merchantType == MerchantType.agriShop;

    final widgetOptions = _widgetOptions(isFarmer, isAgriShop);

    // Ensure selected index is within bounds
    if (selectedIndex >= widgetOptions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabProvider.notifier).state = 0;
      });
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
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: HomeBottomNavigationBar(
        selectedIndex: selectedIndex,
        navItems: navItems,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    ref.read(selectedTabProvider.notifier).state = index;
  }

  List<Widget> _widgetOptions(bool isFarmer, bool isAgriShop) {
    if (isFarmer) {
      return [
        const FarmerDashboardScreen(),
        const MarketplaceScreen(),
        const CropsScreen(),
        const FarmerInventoryScreen(),
        const ProfileScreen(),
      ];
    } else if (isAgriShop) {
      return [
        const AgriShopDashboardScreen(),
        const MarketplaceScreen(),
        const MerchantInventoryScreen(),
        const AgriShopOrdersScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Default to merchant dashboard for other merchant types
      return [
        const MerchantDashboardScreen(),
        const MarketplaceScreen(),
        const MerchantInventoryScreen(),
        const ProfileScreen(),
      ];
    }
  }
}
