import 'package:flutter/material.dart';

import '../services/language_service.dart';
import '../services/shopping_services.dart';
import 'fridge_screen.dart';
import 'home_screen.dart';
import 'my_recipes_screen.dart';
import 'shopping_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    FridgeScreen(),
    ShoppingScreen(),
    MyRecipesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ValueListenableBuilder<List<ShoppingItem>>(
        valueListenable: ShoppingService.items,
        builder: (context, items, _) {
          final pendingCount = items.where((e) => !e.isBought).length;

          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: context.tr('Eksplor', 'Explore'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.kitchen_outlined),
                selectedIcon: const Icon(Icons.kitchen),
                label: context.tr('Isi Kulkas', 'My Fridge'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: context.tr('Belanja', 'Shopping'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: context.tr('Resep Saya', 'My Recipes'),
              ),
            ],
          );
        },
      ),
    );
  }
}