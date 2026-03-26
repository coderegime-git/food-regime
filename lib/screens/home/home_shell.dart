// lib/screens/home/main_shell.dart
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
    _NavTab(icon: Icons.home_rounded, label: 'Home', route: AppRoutes.home),
    // _NavTab(
    //     icon: Icons.search_rounded, label: 'Search', route: AppRoutes.search),
    // _NavTab(
    //     icon: Icons.shopping_cart_rounded,
    //     label: 'Cart',
    //     route: AppRoutes.cart),
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
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => context.go(_tabs[i].route),
          items: _tabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.icon, color: AppColors.primary),
                  label: t.label,
                  tooltip: t.label,
                ),
              )
              .toList(),
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
