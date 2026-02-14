import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavigationBarItem> navItems;
  final Function(int) onItemTapped;
  const HomeBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.navItems,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF2D6A4F),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
