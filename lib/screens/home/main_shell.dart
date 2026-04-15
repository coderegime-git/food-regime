// lib/screens/home/main_shell.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:go_router/go_router.dart';
import '../../model/cart_data.dart';
import '../../model/restauant_detail_data.dart' as res;
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';

final mainShellKey = GlobalKey<_MainShellState>();

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;

  CartData? _cartData;
  int totalCartCount = 0;
  double _totalCartPrice = 0;
  bool cardLoad = false;
  res.Restaurant? restaurant;

  bool _isNavVisible = true;

  // Track previous route to detect return from restaurant detail
  String _previousLocation = '';

  static const _tabs = [
    _NavTab(
        icon: Icons.delivery_dining, label: 'Delivery', route: AppRoutes.home),
    _NavTab(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        route: AppRoutes.orders),
    _NavTab(
        icon: Icons.person_rounded, label: 'Profile', route: AppRoutes.profile),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    fetchCart();
  }

  Future<void> fetchCart() async {
    print("homeee");
    try {
      final result = await ApiService().getCart();
      if (!mounted) return;
      setState(() {
        _cartData = result;
        _totalCartPrice = _cartData?.itemsTotal ?? 0;
        totalCartCount = _cartData?.items?.length ?? 0;
      });

      if (_cartData?.restaurantId != null) {
        await _getRestaurantDetails(_cartData!.restaurantId.toString());
      }
    } catch (e) {
      debugPrint('getCart error: $e');
    }
  }

  Future<void> _getRestaurantDetails(String restaurantId) async {
    setState(() => cardLoad = true);
    try {
      final result = await ApiService().getRestaurantDetails(restaurantId);
      if (!mounted) return;
      setState(() {
        restaurant = result;
        cardLoad = false;
      });
    } catch (e) {
      setState(() => cardLoad = false);
      debugPrint('getRestaurantDetails error: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // FIX 2: Ignore bouncing scroll (overscroll beyond bounds)
  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;

      // Ignore bouncing: only react when scroll is within content bounds
      final outOfBounds = metrics.pixels < metrics.minScrollExtent ||
          metrics.pixels > metrics.maxScrollExtent;
      if (outOfBounds) return;

      final delta = notification.scrollDelta ?? 0;

      if (delta > 2 && _isNavVisible) {
        _isNavVisible = false;
        _animController.forward();
      } else if (delta < -2 && !_isNavVisible) {
        _isNavVisible = true;
        _animController.reverse();
      }
    }
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 0 : idx;
  }

  void _goToConfirm() async {
    if (_cartData == null) return;

    context.push(
      AppRoutes.confirmOrder,
      extra: {
        'restaurant': restaurant,
        'cartData': _cartData!,
        'onIncrement': _increment,
        'onDecrement': _decrement,
      },
    ).then((_) => fetchCart()); // refresh cart when coming back
  }

  Future<void> _increment(CartDataItem cartItem) async {
    debugPrint(cartItem.quantity.toString());
    debugPrint("cartItem.quantity");
    debugPrint(_totalCartPrice.toString());
    final newQty = cartItem.quantity! + 1;
    await ApiService().updateCart(
      cartItemId: cartItem.id ?? 0,
      quantity: newQty,
    );
    await fetchCart();
  }

  Future<void> _decrement(CartDataItem cartItem) async {
    setState(() => cardLoad = true);
    try {
      if (cartItem.quantity == 1) {
        await ApiService().removeCart(cartItemId: cartItem.id ?? 0);
        if (mounted) Navigator.of(context).pop();
      } else {
        print("update");
        await ApiService().updateCart(
          cartItemId: cartItem.id ?? 0,
          quantity: cartItem.quantity! - 1,
        );
      }
      await fetchCart();
    } finally {
      setState(() => cardLoad = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (_previousLocation.contains('restaurant') &&
        !currentLocation.contains('restaurant')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => fetchCart());
    }
    _previousLocation = currentLocation;

    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScrollNotification(notification);
          return false;
        },
        child: Stack(
          children: [
            // Main page content
            Positioned.fill(child: widget.child),

            // Cart bar — animates with nav bar using AnimatedBuilder
            if (totalCartCount > 0 && restaurant != null)
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  // navBarHeight: full height of nav area (safeArea + padding + bar)
                  const double navBarHeight = 85;
                  const double cartBarHeight =
                      70; // adjust to your CartBottomBar height

                  // When nav is fully visible: _animController.value = 0
                  // When nav is fully hidden:  _animController.value = 1
                  // Cart bottom should go from navBarHeight → 10 as nav hides
                  final cartBottom = (navBarHeight + 40) +
                      (_animController.value *
                          -70); // moves 40px DOWN when nav hides // moves 40px UP when nav hides

                  return Positioned(
                    bottom: cartBottom,
                    left: 16,
                    right: 16,
                    height: cartBarHeight,
                    child: child!,
                  );
                },
                child: CartBottomBar(
                  restaurant: restaurant!,
                  cardLoad: cardLoad,
                  count: totalCartCount,
                  total: _totalCartPrice,
                  onTap: _goToConfirm,
                  onDismiss: () {
                    setState(() {
                      totalCartCount = 0;
                      _cartData = null;
                    });
                  },
                ),
              ),
          ],
        ),
      ),

      // Nav bar slides down on scroll
      bottomNavigationBar: SlideTransition(
        position: _slideAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 18, right: 18),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (index) {
                  final t = _tabs[index];
                  final isSelected = currentIndex == index;

                  return GestureDetector(
                    onTap: () {
                      if (!_isNavVisible) {
                        _isNavVisible = true;
                        _animController.reverse();
                      }
                      context.go(t.route);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.primary.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(40),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
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
