import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/screens/crops_screen.dart';
import 'package:agricola/features/home/screens/farmer_dashboard_screen.dart';
import 'package:agricola/features/inventory/screens/farmer_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    FarmerDashboardScreen(),
    CropsScreen(),
    FarmerInventoryScreen(),
    Center(child: Text('Loss Calculator (Coming Soon)')),
    Center(child: Text('Settings (Coming Soon)')),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: t('dashboard', currentLang),
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
          ],
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
