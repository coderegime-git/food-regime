// lib/screens/home/restaurant_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/theme/app_colors.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';

import '../../constants/app_constants.dart';
import '../../model/cart_data.dart';
import '../../model/home_data.dart' show Coupon;
import '../../model/restauant_detail_data.dart';
import '../../utils/helper.dart';
import '../../widgets/empty_card.dart';
import '../order/confirm_order_screen.dart';
import 'main_shell.dart';

const kPrimary = AppColors.primary;
const kPrimaryLight = Color(0xFFFFF4EE);
const kBg = Colors.white;
const kText = Color(0xFF1A1A1A);
const kSubText = Color(0xFF888888);
const kVeg = Color(0xFF22C55E);

// ─────────────────────────────────────────────
// RESTAURANT DETAIL PAGE
// ─────────────────────────────────────────────

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailScreen> {
  final List<CartDataItem> _cart = [];
  CartData? _cartData;

  bool _isLoading = false;
  bool isLoading = false;
  late Restaurant restaurant;
  final apiService = ApiService();
  final Map<String, bool> _expandedSections = {};

  @override
  initState() {
    getRestaurantDetails();
    super.initState();
  }

  Future<void> _fetchCart() async {
    try {
      final res = await apiService.getCart();
      setState(() => _cartData = res);
      if (_cartData != null) {
        _totalCartPrice = _cartData!.itemsTotal ?? 0;
        totalCartCount = _cartData!.items!.length;
      }
    } catch (e) {
      debugPrint('getCart error: $e');
    }
  }

  getRestaurantDetails() async {
    setState(() {
      isLoading = true;
    });
    _fetchCart();

    restaurant = await apiService.getRestaurantDetails(widget.restaurantId);
    setState(() {
      isLoading = false;
    });
  }

  CartDataItem? _cartEntry(MenuItem item) {
    try {
      print("cartEntry");
      print(item.id);
      print(_cart.length);
      print(_cart.length);
      for (var i in _cart) {
        print(i.id);
      }

      return _cartData?.items!.firstWhere((c) => c.menuItemId == item.id);
    } catch (_) {
      return null;
    }
  }

  int totalCartCount = 0;

  double _totalCartPrice = 0;

  Future<void> _addToCart(MenuItem item) async {
    if (_isLoading) return;

    try {
      final cartRestaurantId = _cartData?.restaurantId?.toString();

      // 🟡 Different restaurant → ask confirmation
      if (cartRestaurantId != null && cartRestaurantId != widget.restaurantId) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Replace Cart"),
              content: const Text(
                "Your cart contains items from another restaurant. Do you want to clear the cart and add this item?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        );

        // ❌ User cancelled
        if (confirm != true) return;

        setState(() => _isLoading = true);

        // 👉 Clear cart first
        await apiService.removeAllCart();
      }

      // 🟢 Add to cart (for all valid cases)
      setState(() => _isLoading = true);

      await apiService.addCart(
        menuItemId: item.id,
        quantity: 1,
      );

      await _fetchCart();
      await mainShellKey.currentState?.fetchCart();
    } catch (e) {
      print("Add to cart error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _increment(CartDataItem cartItem) async {
    debugPrint(cartItem.quantity.toString());
    debugPrint("cartItem.quantity");
    debugPrint(_totalCartPrice.toString());
    final newQty = cartItem.quantity! + 1;
    await apiService.updateCart(
      cartItemId: cartItem.id ?? 0,
      quantity: newQty,
    );
    await _fetchCart();
    await mainShellKey.currentState?.fetchCart();
  }

  Future<void> _decrement(CartDataItem cartItem) async {
    setState(() => _isLoading = true);
    try {
      if (cartItem.quantity == 1) {
        await apiService.removeCart(cartItemId: cartItem.id ?? 0);
        if (mounted) Navigator.of(context).pop();
      } else {
        print("update");
        await apiService.updateCart(
          cartItemId: cartItem.id ?? 0,
          quantity: cartItem.quantity! - 1,
        );
      }
      await _fetchCart();
      await mainShellKey.currentState?.fetchCart();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── navigate to confirm ───────────────────────

  void _goToConfirm() {
    if (_cartData == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => ConfirmOrderPage(
            restaurant: restaurant,
            cartData: _cartData!,
            onIncrement: _increment,
            onDecrement: _decrement,
          ),
        ))
        .then((_) => _fetchCart()); // refresh cart when coming back
  }

  // ── build ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: kBg,
        body: AppDefaultLoader(
          loading: isLoading,
          color: kBg,
        ),
      );
    }
    final r = restaurant;
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(r),
              SliverToBoxAdapter(child: _buildRestaurantInfo(r)),
              SliverToBoxAdapter(child: _buildMenuSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Cart bar
          if (totalCartCount > 0)
            Positioned(
              bottom: 5,
              left: 16,
              right: 16,
              child: SafeArea(
                child: _CartBar(
                  count: totalCartCount,
                  total: _totalCartPrice,
                  onTap: _goToConfirm,
                ),
              ),
            ),
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(
                    child: AppDefaultLoader(
                  color: kPrimary,
                  loading: _isLoading,
                )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Restaurant r) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: kText,
      leadingWidth: 50,
      leading: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300, spreadRadius: 1, blurRadius: 1)
            ]),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: kText,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: r.restaurantImage,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: const Color(0xFFFFDDC1)),
              placeholder: (_, __) => const AppDefaultLoader(loading: true),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(Restaurant r) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.businessName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: r.isAcceptingOrders
                      ? const Color(0xFFE6F9EE)
                      : const Color(0xFFFFF0EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: r.isAcceptingOrders ? kVeg : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      r.isAcceptingOrders ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: r.isAcceptingOrders ? kVeg : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: kSubText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${r.address}, ${r.pincode}',
                  style: const TextStyle(fontSize: 13, color: kSubText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                label: r.avgRating == 0
                    ? 'New'
                    : '${r.avgRating} (${r.totalRatings})',
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.delivery_dining_outlined,
                iconColor: kPrimary,
                label: r.baseFee == 0
                    ? 'Free Delivery'
                    : '₹${r.baseFee.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.access_time_rounded,
                iconColor: kPrimary,
                label: '30–40 min',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    // Group items by category
    final Map<String, List<MenuItem>> grouped = {};
    for (final item in restaurant.vegMenu) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    // Also include non-veg if present (future-proof)
    // Initialize expanded state — default all expanded
    for (final key in grouped.keys) {
      _expandedSections.putIfAbsent(key, () => true);
    }

    final totalItems = restaurant.vegMenu.length;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalItems items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (grouped.isEmpty)
            EmptyState.noMenu(
              onAction: () => Navigator.of(context).pop(),
            ),
          ...grouped.entries.indexed.map((record) {
            final index = record.$1;
            final entry = record.$2;
            final category = entry.key;
            final items = entry.value;

            final isExpanded = _expandedSections[category] ?? true;
            final label = category/*== 'veg' ? '🥦 Veg' : '🍗 Non-Veg'*/;
            return Column(
              children: [
                if (index != 0)
                  Divider(
                    height: 25,
                    thickness: 5,
                    color: Colors.grey.shade200,
                  ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _expandedSections[category] = !isExpanded),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.04),
                        //     blurRadius: 8,
                        //     offset: const Offset(0, 2),
                        //   )
                        // ],
                        ),
                    child: Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${items.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Expand / Less label
                        Text(
                          isExpanded ? '▲' : '▼',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // if (!isExpanded)

                // Animated items list
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ...items.indexed.map((record) {
                          final index = record.$1;
                          final item = record.$2;
                          final cartEntry = _cartEntry(item);
                          return _MenuCard(
                            item: item,
                            items: items,
                            index: index,
                            cartEntry: cartEntry,
                            onAdd: _addToCart,
                            onIncrement: _increment,
                            onDecrement: _decrement,
                          );
                        }),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU CARD
// ─────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final int index;
  final List<MenuItem> items;
  final CartDataItem? cartEntry;
  final ValueChanged<MenuItem> onAdd;
  final ValueChanged<CartDataItem> onIncrement;
  final ValueChanged<CartDataItem> onDecrement;

  const _MenuCard({
    required this.item,
    required this.index,
    required this.items,
    required this.cartEntry,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.all(14),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(16),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.05),
          //       blurRadius: 10,
          //       offset: const Offset(0, 2),
          //     )
          //   ],
          // ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image / placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image != null
                    ? CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover)
                    : Container(
                        width: 82,
                        height: 82,
                        color: const Color(0xFFFFEAD9),
                        child: const Center(
                          child: Text('🍛', style: TextStyle(fontSize: 32)),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg badge + name
                    Row(
                      children: [
                        _VegBadge(isVeg: item.category == 'veg'),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: kText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 12, color: kSubText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kPrimary,
                          ),
                        ),
                        if (!item.isAvailable)
                          const Text(
                            'Unavailable',
                            style: TextStyle(
                                fontSize: 12,
                                color: kSubText,
                                fontStyle: FontStyle.italic),
                          )
                        else if (cartEntry != null)
                          _Stepper(
                            value: cartEntry!.quantity ?? 0,
                            onInc: () => onIncrement(cartEntry!),
                            onDec: () => onDecrement(cartEntry!),
                          )
                        else
                          _AddButton(onTap: () => onAdd(item)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (index != items.length - 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const _DashedDivider(
              showCut: false,
            ),
          )
      ],
    );
  }
}
// ─────────────────────────────────────────────
// CONFIRM ORDER PAGE
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// coupon_page.dart  +  updated ConfirmOrderPage
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
// 1.  COUPON PAGE
// ══════════════════════════════════════════════════════════════════════════════

class CouponPage extends StatefulWidget {
  /// The live order total (items_total) used for validation
  final double orderTotal;

  /// Called when the user successfully applies a coupon.
  /// Returns the applied coupon code so ConfirmOrderPage can re-fetch preview.
  final ValueChanged<String> onCouponApplied;

  /// Currently applied coupon (so the page can show it pre-selected)
  final String? appliedCouponCode;

  const CouponPage({
    super.key,
    required this.orderTotal,
    required this.onCouponApplied,
    this.appliedCouponCode,
  });

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  final _codeCtrl = TextEditingController();
  final _apiService = ApiService();

  List<Coupon> _coupons = [];
  bool _loadingCoupons = true;

  String? _validatingCode; // code currently being validated/applied
  String? _appliedCode; // successfully applied code
  String? _errorMsg; // inline error for manual entry

  @override
  void initState() {
    super.initState();
    _appliedCode = widget.appliedCouponCode;
    _loadCoupons();
  }

  void _loadCoupons() {
    // AppConstants.coupon holds the saved coupon list (List<Coupons>)
    setState(() {
      _coupons = AppConstants.coupons ?? [];
      _loadingCoupons = false;
    });
  }

  // ── Validate then Apply ────────────────────────────────────────────────────

  Future<void> _validateAndApply(String code) async {
    if (_validatingCode != null) return;
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      setState(() => _errorMsg = 'Please enter a coupon code.');
      return;
    }

    setState(() {
      _validatingCode = trimmed;
      _errorMsg = null;
    });

    try {
      final validateRes = await _apiService.validateCoupon(
        code: trimmed,
        orderTotal: widget.orderTotal.toString(),
      );

      if (validateRes['statusCode'] != 1) {
        setState(() {
          _errorMsg = validateRes['message'] ?? 'Invalid or Expired coupon.';
          _validatingCode = null;
        });
        return;
      }

      // Step 2 – apply
      final applyRes = await _apiService.applyCoupon(code: trimmed);

      if (applyRes['statusCode'] != 1) {
        setState(() {
          _errorMsg = applyRes['message'] ?? 'Failed to apply coupon.';
          _validatingCode = null;
        });
        return;
      }

      // Success
      setState(() {
        _appliedCode = trimmed;
        _validatingCode = null;
        _errorMsg = null;
      });

      Helper().showToast(context, applyRes['message'], 1);

      // Notify parent – parent will re-fetch checkout preview
      widget.onCouponApplied(trimmed);

      // Close page after short delay
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop(trimmed);
    } catch (_) {
      setState(() {
        _errorMsg = 'Something went wrong. Please try again.';
        _validatingCode = null;
      });
    }
  }

  // ── Remove applied coupon ─────────────────────────────────────────────────

  void _removeCoupon() {
    setState(() => _appliedCode = null);
    widget.onCouponApplied(''); // empty string = no coupon
    Navigator.of(context).pop('');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        titleSpacing: 0,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(_appliedCode ?? ''),
            child: const Icon(Icons.arrow_back_ios, color: kText),
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade200,
        elevation: 0.5,
        foregroundColor: kText,
        title: const Text(
          'Coupons & Offers',
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18, color: kText),
        ),
      ),
      body: Column(
        children: [
          if (widget.orderTotal > 0) _buildManualEntry(),
          if (_appliedCode != null) _buildAppliedBanner(),
          Expanded(child: _buildCouponList()),
        ],
      ),
    );
  }

  // ── Manual code entry ──────────────────────────────────────────────────────

  Widget _buildManualEntry() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: const TextStyle(color: kSubText, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFFAF4EF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _errorMsg,
                  ),
                  onSubmitted: (_) => _validateAndApply(_codeCtrl.text),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _validateAndApply(_codeCtrl.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _validatingCode != null &&
                          _validatingCode == _codeCtrl.text.trim().toUpperCase()
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: AppDefaultLoader(
                            color: Colors.white,
                            loading: true,
                          ))
                      : const Text(
                          'APPLY',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ── Applied coupon banner ──────────────────────────────────────────────────

  Widget _buildAppliedBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F9EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF15803D).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🎟️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _appliedCode!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF15803D),
                  ),
                ),
                const Text(
                  'Coupon applied successfully!',
                  style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _removeCoupon,
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF15803D), size: 20),
          )
        ],
      ),
    );
  }

  // ── Available coupons list ─────────────────────────────────────────────────

  Widget _buildCouponList() {
    if (_loadingCoupons) {
      return Center(
          child: AppDefaultLoader(
        color: kPrimary,
        loading: _loadingCoupons,
      ));
    }
    if (_coupons.isEmpty) {
      return const Center(
        child: Text(
          'No coupons available',
          style: TextStyle(color: kSubText, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: _coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CouponCard(
        coupon: _coupons[i],
        isApplied: _appliedCode == _coupons[i].code,
        isValidating: _validatingCode == _coupons[i].code,
        orderTotal: widget.orderTotal,
        onTap: () {
          if (widget.orderTotal <= 0) return;
          if (_appliedCode == _coupons[i].code) {
            _removeCoupon();
          } else {
            _validateAndApply(_coupons[i].code ?? '');
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COUPON CARD WIDGET
// ─────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isApplied;
  final bool isValidating;
  final double orderTotal;
  final VoidCallback onTap;

  const _CouponCard({
    required this.coupon,
    required this.isApplied,
    required this.isValidating,
    required this.orderTotal,
    required this.onTap,
  });

  bool get _meetsMinOrder {
    final min = double.tryParse(coupon.minOrderValue ?? '0') ?? 0;
    return orderTotal >= min;
  }

  @override
  Widget build(BuildContext context) {
    final bool invalid = coupon.isValid == false || !_meetsMinOrder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApplied
              ? kPrimary
              : invalid
                  ? Colors.grey.shade200
                  : const Color(0xFFEDE0D8),
          width: isApplied ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: invalid ? Colors.grey.shade100 : kPrimaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coupon.discountDisplay ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: invalid ? Colors.grey : kPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code
                      Row(
                        children: [
                          Text(
                            coupon.code ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: invalid ? Colors.grey : kText,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isApplied)
                            const Icon(Icons.check_circle_rounded,
                                color: kPrimary, size: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coupon.description ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: invalid ? Colors.grey.shade400 : kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed divider with scissors icon
          _DashedDivider(invalid: invalid),

          // Bottom – min order + apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coupon.minOrderValue != null &&
                          coupon.minOrderValue != '0') ...[
                        Text(
                          'Min order: ₹${coupon.minOrderValue}',
                          style: TextStyle(
                            fontSize: 11,
                            color: !_meetsMinOrder
                                ? Colors.red.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (!_meetsMinOrder)
                        Text(
                          'Add ₹${(double.tryParse(coupon.minOrderValue ?? '0')! - orderTotal).toStringAsFixed(0)} more to use',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (coupon.validTill != null)
                        Text(
                          'Valid till ${_formatDate(coupon.validTill!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: invalid ? null : onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isApplied
                          ? const Color(0xFFFFEEEE)
                          : invalid
                              ? Colors.grey.shade100
                              : kPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isApplied
                            ? Colors.red.shade200
                            : invalid
                                ? Colors.grey.shade200
                                : kPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: isValidating
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: AppDefaultLoader(
                              color: kPrimary,
                              loading: isValidating,
                            ))
                        : Text(
                            isApplied ? 'REMOVE' : 'APPLY',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: isApplied
                                  ? Colors.red
                                  : invalid
                                      ? Colors.grey
                                      : kPrimary,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// Dashed divider with scissors
class _DashedDivider extends StatelessWidget {
  final bool invalid;
  final bool showCut;

  const _DashedDivider({this.invalid = false, this.showCut = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // left notch
        Transform.translate(
          offset: const Offset(-10, 0),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: kBg,
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      invalid ? Colors.grey.shade200 : const Color(0xFFEDE0D8)),
            ),
          ),
        ),
        Expanded(
          child: CustomPaint(
            painter: _DashedLinePainter(
                color:
                    invalid ? Colors.grey.shade200 : const Color(0xFFEDE0D8)),
            child: const SizedBox(height: 1),
          ),
        ),
        // scissors icon
        if (showCut)
          Icon(
            Icons.content_cut_rounded,
            size: 16,
            color: invalid ? Colors.grey.shade300 : kSubText.withOpacity(0.4),
          ),
        // right notch
        Transform.translate(
          offset: const Offset(10, 0),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: kBg,
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      invalid ? Colors.grey.shade200 : const Color(0xFFEDE0D8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashW = 5.0, gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
          Offset(x, 0), Offset((x + dashW).clamp(0, size.width), 0), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
// 2.  CHECKOUT PREVIEW MODEL
// ══════════════════════════════════════════════════════════════════════════════

class CheckoutPreview {
  final int cartId;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantImage;
  final List<CartDataItem> items;
  final double itemsTotal;
  final Map<String, dynamic>? deliveryAddress;
  final double deliveryFee;
  final double platformFee;
  final bool isFreeDelivery;
  final double freeDeliveryThreshold;
  final String? couponCode;
  final double discountAmount;
  final double walletBalance;
  final double walletApplied;
  final double subtotal;
  final double totalAmount;
  final bool hasSubscription;
  final double subscriptionDiscount;

  const CheckoutPreview({
    required this.cartId,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImage,
    required this.items,
    required this.itemsTotal,
    this.deliveryAddress,
    required this.deliveryFee,
    required this.platformFee,
    required this.isFreeDelivery,
    required this.freeDeliveryThreshold,
    this.couponCode,
    required this.discountAmount,
    required this.walletBalance,
    required this.walletApplied,
    required this.subtotal,
    required this.totalAmount,
    required this.hasSubscription,
    required this.subscriptionDiscount,
  });

  factory CheckoutPreview.fromJson(Map<String, dynamic> j) {
    return CheckoutPreview(
      cartId: j['cart_id'] ?? 0,
      restaurantId: j['restaurant_id'] ?? 0,
      restaurantName: j['restaurant_name'] ?? '',
      restaurantImage: j['restaurant_image'],
      items: (j['items'] as List? ?? [])
          .map((i) => CartDataItem.fromJson(i))
          .toList(),
      itemsTotal: (j['items_total'] as num?)?.toDouble() ?? 0,
      deliveryAddress: j['delivery_address'],
      deliveryFee: (j['delivery_fee'] as num?)?.toDouble() ?? 0,
      platformFee: (j['platform_fee'] as num?)?.toDouble() ?? 0,
      isFreeDelivery: j['is_free_delivery'] ?? false,
      freeDeliveryThreshold:
          (j['free_delivery_threshold'] as num?)?.toDouble() ?? 0,
      couponCode: j['coupon_code'],
      discountAmount: (j['discount_amount'] as num?)?.toDouble() ?? 0,
      walletBalance: (j['wallet_balance'] as num?)?.toDouble() ?? 0,
      walletApplied: (j['wallet_applied'] as num?)?.toDouble() ?? 0,
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
      totalAmount: (j['total_amount'] as num?)?.toDouble() ?? 0,
      hasSubscription: j['has_subscription'] ?? false,
      subscriptionDiscount:
          (j['subscription_discount'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3.  UPDATED CONFIRM ORDER PAGE
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// 4.  BILL ROW – updated to support discount rows
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// 5.  API SERVICE ADDITIONS  (add these methods to your existing ApiService)
// ══════════════════════════════════════════════════════════════════════════════

/*

  // GET /checkout/preview/?coupon_code=X&use_wallet=true
  Future<Map<String, dynamic>> getCheckoutPreview({
    String? couponCode,
    bool useWallet = false,
  }) async {
    String url = '${AppConstants.baseUrl}/checkout/preview/';
    final params = <String>[];
    if (couponCode != null && couponCode.isNotEmpty) {
      params.add('coupon_code=$couponCode');
    }
    if (useWallet) params.add('use_wallet=true');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _dio.get(url);
    return response.data;
  }

  // POST /coupon/validate/
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double orderTotal,
  }) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/coupon/validate/',
      data: {'code': code, 'order_total': orderTotal},
    );
    return response.data;
  }

  // POST /coupon/apply/
  Future<Map<String, dynamic>> applyCoupon({required String code}) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/coupon/apply/',
      data: {'code': code},
    );
    return response.data;
  }

*/

// ─────────────────────────────────────────────
// ORDER SUCCESS SCREEN
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final double size;

  const _Stepper({
    required this.value,
    required this.onInc,
    required this.onDec,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(Icons.remove, onDec, outline: true),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        _stepBtn(Icons.add, onInc),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback cb, {bool outline = false}) {
    return GestureDetector(
      onTap: cb,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: outline ? Colors.white : kPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kPrimary, width: 1.5),
        ),
        child: Icon(icon,
            size: size * 0.5, color: outline ? kPrimary : Colors.white),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'ADD',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}

class _VegBadge extends StatelessWidget {
  final bool isVeg;

  const _VegBadge({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? kVeg : Colors.red;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(3)),
      child: Center(
        child: CircleAvatar(radius: 4, backgroundColor: color),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoChip(
      {required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: kText)),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onTap;

  const _CartBar(
      {required this.count, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE2773A), Color(0xFFD4541A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count item${count > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            const Spacer(),
            const Text(
              'View Cart',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            const Spacer(),
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
