// lib/screens/home/main_shell.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The persistent shell wrapping bottom-nav tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = [
    _NavTab(
        icon: Icons.delivery_dining, label: 'Delivery', route: AppRoutes.home),
    //  _NavTab(icon: Icons.search_rounded, label: 'Search', route: AppRoutes.search),
    // _NavTab(icon: Icons.shopping_cart_rounded, label: 'Cart', route: AppRoutes.cart),
    _NavTab(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        route: AppRoutes.orders),
    _NavTab(
        icon: Icons.person_rounded, label: 'Profile', route: AppRoutes.profile),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 18, right: 18),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40), // Oval shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final t = _tabs[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => context.go(t.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.primary.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(40))
                        : null,
                    child: Column(
                      children: [
                        Icon(
                          t.icon,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                        Text(
                          t.label,
                          style: TextStyle(
                              fontSize: 11.5,
                              color:
                                  isSelected ? AppColors.primary : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  final String route;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.route,
  });
}
