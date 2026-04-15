import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../model/search_result_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/api_service.dart';
import '../../widgets/app_loader.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const kAccent = Color(0xFFE2773A);
const kAccentLight = Color(0xFFFFF4EE);
const kBg = Colors.white;
const kText = Color(0xFF1A1A1A);
const kTextLight = Color(0xFF999999);
const kBorder = Color(0xFFEEEEEE);
const kSurface2 = Color(0xFFF8F8F8);
const kGreen = Color(0xFF22C55E);

// ─── Search Screen ────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _apiService = ApiService();

  SearchResult? _result;
  bool _loading = false;
  String? _error;
  String _query = '';

  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _result = null;
        _error = null;
        _query = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _query = q;
    });
    try {
      final res = await _apiService.search(q);
      setState(() => _result = res);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clear() {
    _ctrl.clear();
    setState(() {
      _result = null;
      _error = null;
      _query = '';
    });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.grey.shade200,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: kText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 42,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: (v) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (_ctrl.text == v) _search(v);
            });
          },
          onSubmitted: _search,
          style: const TextStyle(fontSize: 14, color: kText),
          decoration: InputDecoration(
            hintText: 'Search restaurants or dishes...',
            hintStyle: const TextStyle(fontSize: 13, color: kTextLight),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            prefixIcon:
                const Icon(Icons.search_rounded, size: 20, color: kTextLight),
            suffixIcon: _ctrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: _clear,
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: kTextLight),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
      bottom: _result != null && !_result!.isEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: kAccent,
                  indicatorWeight: 3,
                  labelColor: kAccent,
                  unselectedLabelColor: kTextLight,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Restaurants (${_result!.restaurants.length})'),
                    Tab(text: 'Dishes (${_result!.dishes.length})'),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
          child: AppDefaultLoader(
        color: kAccent,
        loading: _loading,
      ));
    }
    if (_error != null) return _ErrorState(message: _error!);
    if (_query.isEmpty) return const _IdleState();
    if (_result == null) return const SizedBox.shrink();
    if (_result!.isEmpty) return _EmptyState(query: _query);

    return TabBarView(
      controller: _tabCtrl,
      children: [
        _RestaurantGrid(
            restaurants: _result!.restaurants,
            onTap: (r) {
              _focus.unfocus();
              context.push(AppRoutes.restaurantDetailPath(r.id.toString()));
            }),
        _DishGrid(
            dishes: _result!.dishes,
            onTap: (d) {
              _focus.unfocus();

              context.push(
                  AppRoutes.restaurantDetailPath(d.restaurantId.toString()));
            }),
      ],
    );
  }
}

class _RestaurantGrid extends StatelessWidget {
  final List<SearchRestaurant> restaurants;
  final ValueChanged<SearchRestaurant> onTap;

  const _RestaurantGrid({required this.restaurants, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const Center(
        child: Text('No restaurants found',
            style: TextStyle(color: kTextLight, fontSize: 14)),
      );
    }
    return MasonryGridView.count(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: restaurants.length,
      itemBuilder: (_, i) => _RestaurantGridCard(
        restaurant: restaurants[i],
        // Alternate tall/short: even index = tall image, odd = short
        imageHeight: i % 3 == 0
            ? 160.0
            : i % 3 == 1
                ? 110.0
                : 135.0,
        onTap: () => onTap(restaurants[i]),
      ),
    );
  }
}

// ─── Dish Grid (Masonry) ──────────────────────────────────────────────────────

class _DishGrid extends StatelessWidget {
  final List<SearchDish> dishes;
  final ValueChanged<SearchDish> onTap;

  const _DishGrid({required this.dishes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) {
      return const Center(
        child: Text('No dishes found',
            style: TextStyle(color: kTextLight, fontSize: 14)),
      );
    }
    return MasonryGridView.count(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: dishes.length,
      itemBuilder: (_, i) => _DishGridCard(
        dish: dishes[i],
        imageHeight: i % 4 == 0
            ? 170.0
            : i % 4 == 1
                ? 110.0
                : i % 4 == 2
                    ? 145.0
                    : 125.0,
        onTap: () => onTap(dishes[i]),
      ),
    );
  }
}

// ─── Restaurant Grid Card ─────────────────────────────────────────────────────

class _RestaurantGridCard extends StatelessWidget {
  final SearchRestaurant restaurant;
  final VoidCallback onTap;
  final double imageHeight;

  const _RestaurantGridCard({
    required this.restaurant,
    required this.onTap,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: r.image != null
                      ? CachedNetworkImage(
                          imageUrl: r.image!,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _ImagePlaceholder(
                              emoji: '🍽️', height: imageHeight),
                          placeholder: (_, __) => _ImagePlaceholder(
                              emoji: '🍽️', height: imageHeight),
                        )
                      : _ImagePlaceholder(emoji: '🍽️', height: imageHeight),
                ),
                // Open/Closed badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.isAcceptingOrders
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          r.isAcceptingOrders ? 'Open' : 'Closed',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.businessName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: kTextLight),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          r.address,
                          style:
                              const TextStyle(fontSize: 11, color: kTextLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: double.parse(r.deliveryFee) == 0
                          ? const Color(0xFFE6F9EE)
                          : kAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delivery_dining_outlined,
                          size: 11,
                          color: double.parse(r.deliveryFee) == 0
                              ? const Color(0xFF16A34A)
                              : kAccent,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          double.parse(r.deliveryFee) == 0
                              ? 'Free Delivery'
                              : '₹${double.parse(r.deliveryFee).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: double.parse(r.deliveryFee) == 0
                                ? const Color(0xFF16A34A)
                                : kAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dish Grid Card ───────────────────────────────────────────────────────────

class _DishGridCard extends StatelessWidget {
  final SearchDish dish;
  final VoidCallback onTap;
  final double imageHeight;

  const _DishGridCard({
    required this.dish,
    required this.onTap,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isVeg = dish.category == 'veg';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: dish.image != null
                      ? CachedNetworkImage(
                          imageUrl: dish.image!,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _ImagePlaceholder(
                              emoji: isVeg ? '🥦' : '🍗',
                              height: imageHeight,
                              color: isVeg
                                  ? const Color(0xFFE6F9EE)
                                  : const Color(0xFFFFEEEE)),
                          placeholder: (_, __) => _ImagePlaceholder(
                              emoji: isVeg ? '🥦' : '🍗',
                              height: imageHeight,
                              color: isVeg
                                  ? const Color(0xFFE6F9EE)
                                  : const Color(0xFFFFEEEE)),
                        )
                      : _ImagePlaceholder(
                          emoji: isVeg ? '🥦' : '🍗',
                          height: imageHeight,
                          color: isVeg
                              ? const Color(0xFFE6F9EE)
                              : const Color(0xFFFFEEEE),
                        ),
                ),
                // Veg badge top-left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isVeg
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVeg ? 'Veg' : 'Non-veg',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isVeg
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Price badge bottom-right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${dish.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 11, color: kTextLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          dish.restaurantName,
                          style:
                              const TextStyle(fontSize: 11, color: kTextLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: kAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        dish.price.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image Placeholder ────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  final String emoji;
  final double height;
  final Color color;

  const _ImagePlaceholder({
    required this.emoji,
    required this.height,
    this.color = kAccentLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }
}

// ─── States (unchanged) ───────────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: kAccentLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for food or restaurants',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: kText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Type to search',
            style: TextStyle(fontSize: 13, color: kTextLight),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: kText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword',
            style: TextStyle(fontSize: 13, color: kTextLight),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: kTextLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
