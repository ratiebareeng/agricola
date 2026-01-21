import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/crops/screens/crops_screen.dart';
import 'package:agricola/features/home/screens/farmer_dashboard_screen.dart';
import 'package:agricola/features/home/screens/merchant_dashboard_screen.dart';
import 'package:agricola/features/inventory/screens/farmer_inventory_screen.dart';
import 'package:agricola/features/inventory/screens/merchant_inventory_screen.dart';
import 'package:agricola/features/marketplace/screens/marketplace_screen.dart';
import 'package:agricola/features/profile/screens/profile_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final profile = ref.watch(profileSetupProvider);
    final isFarmer = profile.userType == UserType.farmer;
    final isAgriShop =
        (profile.merchantType ?? MerchantType.agriShop) ==
        MerchantType.agriShop;

    final List<Widget> widgetOptions = isFarmer
        ? [
            const FarmerDashboardScreen(),
            const MarketplaceScreen(),
            const CropsScreen(),
            const FarmerInventoryScreen(),
            const ProfileScreen(),
          ]
        : [
            const MerchantDashboardScreen(),
            const MarketplaceScreen(),
            const MerchantInventoryScreen(),
            const ProfileScreen(),
          ];

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
              label: isAgriShop
                  ? t('products', currentLang)
                  : t('produce', currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_outlined),
              activeIcon: const Icon(Icons.person),
              label: t('profile', currentLang),
            ),
          ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
