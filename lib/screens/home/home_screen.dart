import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/constants/app_constants.dart';
import 'package:food_delivery_app/model/home_data.dart';
import 'package:food_delivery_app/model/profile_data.dart';
import 'package:food_delivery_app/routes/app_routes.dart';
import 'package:food_delivery_app/screens/home/search_screen.dart';
import 'package:food_delivery_app/screens/profile/saved_addresses_screen.dart';
import 'package:food_delivery_app/theme/app_colors.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/utils/helper.dart';
import 'package:food_delivery_app/utils/sharedpreference_helper.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../model/cart_data.dart';
import '../../model/restauant_detail_data.dart' as res;
import '../order/confirm_order_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static const primary = Color(0xFFE23744);
  static const orange = Color(0xFFFF6B35);
  static const ink = Color(0xFF1C1C1E);
  static const muted = Color(0xFF8A8A8E);
  static const bg = Color(0xFFF7F3EF);
  static const card = Colors.white;
  static const String font = 'Poppins';
}

// ─────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _catIndex = 0;
  late final AnimationController _entranceAc;
  late final AnimationController _heroAc;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;
  late HomeResponse homeData;
  ProfileData? profileData;
  bool isLoad = false;
  final apiService = ApiService();
  final List<CartDataItem> _cart = [];
  CartData? _cartData;
  int totalCartCount = 0;

  double _totalCartPrice = 0;
  bool cardLoad = false;
  late res.Restaurant restaurant;
  ScrollController _scrollController = ScrollController();

  bool isLoadingMore = false;
  bool hasNextPage = true;
  List<Restaurant> restaurantList = [];

  @override
  void initState() {
    super.initState();
    _entranceAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _init();
  }

  getRestaurantDetails(restaurantId) async {
    setState(() {
      cardLoad = true;
    });

    restaurant = await apiService.getRestaurantDetails(restaurantId);
    setState(() {
      cardLoad = false;
    });
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
  }

  Future<void> _decrement(CartDataItem cartItem) async {
    setState(() => cardLoad = true);
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
    } finally {
      setState(() => cardLoad = false);
    }
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
    ).then((_) => _fetchCart()); // refresh cart when coming back
  }

  Future<void> _fetchCart() async {
    try {
      final res = await apiService.getCart();
      setState(() => _cartData = res);
      if (_cartData != null) {
        _totalCartPrice = _cartData!.itemsTotal ?? 0;
        totalCartCount = _cartData!.items!.length;
        if (_cartData != null && _cartData!.restaurantId != null) {
          await getRestaurantDetails(_cartData!.restaurantId.toString());
        }
      }
      setState(() {});
    } catch (e) {
      debugPrint('getCart error: $e');
    }
  }

  Future<void> _init() async {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasNextPage) {
        loadMoreRestaurants();
      }
    });
    await getHomeData();
    _setupAnimations();
  }

  Future<void> loadMoreRestaurants() async {
    if (homeData.restaurants?.next == null) {
      hasNextPage = false;
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    final data = await apiService.getHomeData(homeData.restaurants!.next!);

    setState(() {
      restaurantList.addAll(data.restaurants!.results ?? []);
      homeData.restaurants!.next = data.restaurants!.next;
      isLoadingMore = false;
    });
  }

  Future<void> getHomeData() async {
    setState(() => isLoad = true);
    homeData = await apiService.getHomeData(1);
    profileData = SharedPreferenceHelper.getUserObject();
    if (homeData.data != null) {
      restaurantList = homeData.restaurants?.results ?? [];

      AppConstants.coupons = homeData.data!.coupons;
      AppConstants.categories = homeData.data!.categories;
    }
    if (profileData?.data != null) {
      final user = profileData!.data!;
      if (user.defaultAddress == null) await buildAddress();
      if ((user.name ?? '').isEmpty) await _goToEditProfile();
    }
    await _fetchCart();

    setState(() => isLoad = false);
  }

  Future<void> _goToEditProfile() async {
    await context.push(AppRoutes.editProfilePath('fromHome'));
    profileData = SharedPreferenceHelper.getUserObject();
    if ((profileData?.data?.name ?? '').isEmpty) {
      Helper().showToast(context, 'Please save your name', 0);
      await context.push(AppRoutes.editProfilePath('fromHome'));
      final data = await ApiService().getProfile();
      SharedPreferenceHelper.setUserObject(data);
    }
  }

  void _setupAnimations() {
    _slideAnims = List.generate(6, (i) {
      final start = i * 0.10;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceAc,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _fadeAnims = List.generate(6, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceAc,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 80), () {
      _heroAc.forward();
      _entranceAc.forward();
    });
  }

  @override
  void dispose() {
    _entranceAc.dispose();
    _heroAc.dispose();
    super.dispose();
  }

  Widget _animate(int i, Widget child) =>
      FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  Future<void> buildAddress() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: false,
      isDismissible: false,
      useSafeArea: true,
      builder: (_) => const SafeArea(child: SavedAddressesScreen()),
    );
    final data = await ApiService().getProfile();
    SharedPreferenceHelper.setUserObject(data);
    profileData = SharedPreferenceHelper.getUserObject();
    setState(() {});
  }

  Widget _pRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () async {
        await context.push(AppRoutes.restaurantDetailPath(
          restaurant.id.toString(),
        ));
        _fetchCart();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with shadow effect
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: restaurant.image ?? "",
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.businessName ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("⭐ ${restaurant.rating?.average ?? 0}",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      Text("${restaurant.distance ?? 0} km",
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      return Scaffold(
        backgroundColor: _T.bg,
        body: AppDefaultLoader(loading: isLoad, color: _T.bg),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HERO STACK (video-style animated banner + header overlay)
              SliverToBoxAdapter(
                child: _HeroStack(
                  profileData: profileData,
                  coupons: homeData.data?.coupons ?? [],
                  onAddressTap: buildAddress,
                ),
              ),

              // ── CATEGORIES
              if (AppConstants.categories != null)
                SliverToBoxAdapter(
                  child: _animate(
                    1,
                    _CategoriesRow(
                      selected: _catIndex,
                      onSelect: (i) => setState(() => _catIndex = i),
                    ),
                  ),
                ),

              // ── POPULAR PICKS
              if (homeData.data?.popularFoods != null)
                SliverToBoxAdapter(
                  child: _animate(
                    2,
                    PopularFoodSection(foods: homeData.data!.popularFoods!),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.lightBlue.shade200,
                        Colors.lightBlue.shade100,
                        Colors.white,
                      ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Newly featured for you",
                          style: TextStyle(
                              fontSize: 16,
                              color: _T.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 310,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: homeData.data!.popularRestaurants!.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 rows
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.2,
                          ),
                          itemBuilder: (context, index) {
                            return _pRestaurantCard(
                              homeData.data!.popularRestaurants![index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              // ── ALL RESTAURANTS heading
              SliverToBoxAdapter(
                child: _animate(
                  3,
                  const _SectionHeading(
                    title: 'All Restaurants',
                    sub: 'Delivering near you',
                  ),
                ),
              ),

              // ── RESTAURANT LIST
              if (homeData.restaurants?.results != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      if (i == 4) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            _PopularSection(homeData.data!.popularFoods!),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      }

                      final index = i > 4 ? i - 1 : i;
                      if (index >= restaurantList.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: _T.primary,
                            ),
                          ),
                        );
                      }

                      return _animate(
                        4,
                        _RestaurantCard(
                            r: homeData.restaurants!.results![index]),
                      );
                    },
                    childCount: homeData.restaurants!.results!.length + 1,
                  ),
                ),
              // SliverToBoxAdapter(
              //   child: PopularRestaurantsScreen(
              //       restaurants: homeData.data!.popularRestaurants ?? []),
              // ),

              SliverToBoxAdapter(
                child: isLoadingMore
                    ? const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    SizedBox(
                      height: 120,
                    )
                  ],
                )
                    : const SizedBox(),
              ),
              if (!isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Still hungry? 😋",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "We’ve got more tasty dishes waiting for you!",
                          textAlign: TextAlign.center,
                        ),
                        Image.asset(
                          "assets/images/end.jpg",
                          height: 200,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              // const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          if (totalCartCount > 0)
            Positioned(
              bottom: 130,
              left: 16,
              right: 16,
              child: CartBottomBar(
                restaurant: restaurant,
                cardLoad: cardLoad,
                count: totalCartCount,
                total: _totalCartPrice,
                onTap: _goToConfirm,
                onDismiss: () {},
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO STACK  ← the main new component
//  Layers:  animated canvas (simulates video) → offer PageView → overlay UI
// ─────────────────────────────────────────────────────────────────────────────
class _HeroStack extends StatefulWidget {
  ProfileData? profileData;
  final List<Coupon> coupons;
  final VoidCallback onAddressTap;

  _HeroStack({
    required this.profileData,
    required this.coupons,
    required this.onAddressTap,
  });

  @override
  State<_HeroStack> createState() => _HeroStackState();
}

class _HeroStackState extends State<_HeroStack> with TickerProviderStateMixin {
  late final AnimationController _bgAc;
  late final PageController _pageCtrl;
  int _currentPage = 0;

  // Food GIF URLs (looping food animations from giphy public CDN)
  static const _foodGifs = [
    // burger sizzle

    'assets/images/flash_sale.mp4',
    'assets/images/discount.mp4',
    'assets/images/offers_video.mp4',

    // pizza
    'assets/images/offers_video.mp4',
    // noodles
    'assets/images/offers_video.mp4',
    // tacos
  ];

  static const _offerColors = [
    [Color(0xFF0D0D0D), Color(0xFF8B0000)],
    [Color(0xFF001F3F), Color(0xFF0074D9)],
    [Color(0xFF1A0030), Color(0xFF7B2D8B)],
    [Color(0xFF003300), Color(0xFF006400)],
  ];

  @override
  void initState() {
    super.initState();
    _bgAc = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )
      ..repeat();
    _pageCtrl = PageController();

    // Auto-scroll banners
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_currentPage + 1) % math.max(widget.coupons.length, 1);
    _pageCtrl.animateToPage(
      next.toInt(),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(seconds: 10), _autoScroll);
  }

  @override
  void dispose() {
    _bgAc.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery
        .of(context)
        .padding
        .top;
    final h = MediaQuery
        .of(context)
        .size
        .height * 0.52;

    return SizedBox(
      height: h + 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Layer 1: Animated lava-lamp background (simulates rich video bg)
          // Positioned.fill(
          //   child: AnimatedBuilder(
          //     animation: _bgAc,
          //     builder: (_, __) => CustomPaint(
          //       painter: _LavaLampPainter(_bgAc.value),
          //     ),
          //   ),
          // ),

          // ── Layer 2: Food GIF (right side, clipped)
          Positioned.fill(
            right: -20,
            left: -20,
            bottom: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _AnimatedFoodGif(
                gifUrls: _foodGifs,
                pageIndex: _currentPage,
              ),
            ),
          ),

          //  ── Layer 3: Offer card PageView (center-left)
          Positioned(
            left: 0,
            right: 0,
            bottom: -25,
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: math.max(widget.coupons.length, 1),
                    itemBuilder: (_, i) {
                      final coupon = widget.coupons.isNotEmpty
                          ? widget.coupons[i % widget.coupons.length]
                          : null;
                      final colors = _offerColors[i % _offerColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _OfferCard(
                          coupon: coupon,
                          colors: colors,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    math.max(widget.coupons.length, 1),
                        (i) =>
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == i ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location row
                  GestureDetector(
                    onTap: widget.onAddressTap,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _T.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivering to',
                                  style: TextStyle(
                                    fontFamily: _T.font,
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.65),
                                    letterSpacing: 0.3,
                                  )),
                              const SizedBox(height: 1),
                              Row(children: [
                                Flexible(
                                  child: Text(
                                    widget.profileData?.data?.defaultAddress
                                        ?.fullAddress ??
                                        'Select address',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: _T.font,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white, size: 16),
                              ]),
                            ],
                          ),
                        ),
                        // Notification
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.notifications);
                          },
                          child: const _IconPill(
                            icon: Icons.notifications_outlined,
                            badge: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar
                        GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.editProfile);
                              widget.profileData =
                                  SharedPreferenceHelper.getUserObject();
                              setState(() {});
                            },
                            child:
                            _AvatarPill(profileData: widget.profileData)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search bar
                  _HeroSearch(),

                  const SizedBox(height: 14),

                  // Tagline
                  // const Text(
                  //   'What\'s on your\nmind today? 🔥',
                  //   style: TextStyle(
                  //     fontFamily: _T.font,
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.w800,
                  //     color: Colors.white,
                  //     height: 1.25,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // ── Layer 5: Bottom curved clip to blend into content
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 28,
          //     decoration: BoxDecoration(
          //       color: _T.bg,
          //       borderRadius: const BorderRadius.vertical(
          //         top: Radius.circular(28),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated Food GIF switcher (cross-fades between food gifs)
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedFoodGif extends StatefulWidget {
  final List<String> gifUrls;
  final int pageIndex;

  const _AnimatedFoodGif({
    required this.gifUrls,
    required this.pageIndex,
  });

  @override
  State<_AnimatedFoodGif> createState() => _AnimatedFoodGifState();
}

class _AnimatedFoodGifState extends State<_AnimatedFoodGif> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() {
    final url = widget.gifUrls[widget.pageIndex];

    _controller = VideoPlayerController.asset(url)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant _AnimatedFoodGif oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _controller.dispose();
      _loadVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(width: 170, height: 170);
    }

    return SizedBox(
      child: VideoPlayer(_controller),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Offer Card (inside hero PageView)
// ─────────────────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final Coupon? coupon;
  final List<Color> colors;

  const _OfferCard({this.coupon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.55),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _T.primary.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          coupon?.minOrderValue ?? 'LIMITED OFFER',
                          style: const TextStyle(
                            fontFamily: _T.font,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coupon?.code ?? 'SAVE50',
                        style: const TextStyle(
                          fontFamily: _T.font,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon?.description ??
                            'Get flat 50% off on first order',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _T.font,
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Redeem button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'USE NOW',
                        style: TextStyle(
                          fontFamily: _T.font,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.last,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: _T.primary.withOpacity(0.8), size: 20),
            const SizedBox(width: 8),
            Text(
              'Search food, restaurants…',
              style: TextStyle(
                fontFamily: _T.font,
                fontSize: 13,
                color: _T.ink.withOpacity(0.35),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              height: 28,
              width: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            const SizedBox(width: 12),
            Icon(Icons.mic_rounded, color: _T.ink.withOpacity(0.3), size: 18),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Icon Pill (notification)
// ─────────────────────────────────────────────────────────────────────────────
class _IconPill extends StatelessWidget {
  final IconData icon;
  final bool badge;

  const _IconPill({required this.icon, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border:
            Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        if (badge)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: _T.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Avatar Pill
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarPill extends StatelessWidget {
  final ProfileData? profileData;

  const _AvatarPill({this.profileData});

  @override
  Widget build(BuildContext context) {
    final initial = profileData?.data?.name?.isNotEmpty == true
        ? profileData!.data!.name![0].toUpperCase()
        : 'U';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_T.primary, _T.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: _T.font,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LAVA LAMP PAINTER (animated background — simulates rich video texture)
// ─────────────────────────────────────────────────────────────────────────────
class _LavaLampPainter extends CustomPainter {
  final double t;

  _LavaLampPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark base
    final bg = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF0D0000), Color(0xFF1A0A00), Color(0xFF2D0505)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Animated blobs
    final blobs = [
      _BlobDef(
        cx: size.width * (0.2 + 0.15 * math.sin(t * math.pi * 2)),
        cy: size.height * (0.3 + 0.12 * math.cos(t * math.pi * 2 * 0.7)),
        r: size.width * 0.38,
        color: const Color(0xFFE23744).withOpacity(0.22),
      ),
      _BlobDef(
        cx: size.width * (0.75 + 0.1 * math.cos(t * math.pi * 2 * 1.3)),
        cy: size.height * (0.5 + 0.18 * math.sin(t * math.pi * 2 * 0.9)),
        r: size.width * 0.32,
        color: const Color(0xFFFF6B35).withOpacity(0.18),
      ),
      _BlobDef(
        cx: size.width * (0.5 + 0.2 * math.sin(t * math.pi * 2 * 0.5)),
        cy: size.height * (0.7 + 0.1 * math.cos(t * math.pi * 2 * 1.1)),
        r: size.width * 0.28,
        color: const Color(0xFFC0392B).withOpacity(0.15),
      ),
    ];

    for (final b in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.color, b.color.withOpacity(0)],
        ).createShader(Rect.fromCircle(
          center: Offset(b.cx, b.cy),
          radius: b.r,
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset(b.cx, b.cy), b.r, paint);
    }

    // Noise grid overlay
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.6;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
        radius: 1.1,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(_LavaLampPainter old) => old.t != t;
}

class _BlobDef {
  final double cx, cy, r;
  final Color color;

  _BlobDef({
    required this.cx,
    required this.cy,
    required this.r,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORIES ROW
// ─────────────────────────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _CategoriesRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: "What brings you here today?", sub: null),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: AppConstants.categories?.length ?? 0,
            itemBuilder: (_, i) {
              final data = AppConstants.categories![i];
              final sel = selected == i;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _T.primary : _T.card,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: sel ? _T.primary : Colors.grey.shade100,
                      width: 1.5,
                    ),
                    boxShadow: sel
                        ? [
                      BoxShadow(
                        color: _T.primary.withOpacity(0.38),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: sel
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.shade100,
                        backgroundImage: (data.image?.isNotEmpty == true)
                            ? CachedNetworkImageProvider(data.image!)
                            : null,
                        child: (data.image?.isEmpty != false)
                            ? Icon(Icons.fastfood,
                            size: 14, color: sel ? Colors.white : _T.muted)
                            : null,
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 45,
                        child: Text(
                          textAlign: TextAlign.center,
                          data.name ?? '',
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: _T.font,
                            fontSize: 11,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color:
                            sel ? Colors.white : _T.ink.withOpacity(0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  POPULAR SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PopularSection extends StatelessWidget {
  final List<PopularFood> items;

  const _PopularSection(this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            title: 'Popular Picks 🔥',
            sub: 'Most ordered this week',
          ),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: items.length,
              itemBuilder: (_, i) => _PopularCard(item: items[i], index: i),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final PopularFood item;
  final int index;

  const _PopularCard({required this.item, required this.index});

  static const _accents = [
    Color(0xFFBF360C),
    Color(0xFF1B5E20),
    Color(0xFF006064),
    Color(0xFF3E2723),
    Color(0xFF880E4F),
  ];

  @override
  Widget build(BuildContext context) {
    final p = item;
    final accent = _accents[index % _accents.length];

    return GestureDetector(
      onTap: () async {
        final GlobalKey<_HomeScreenState> homeKey = GlobalKey();

        await context
            .push(AppRoutes.restaurantDetailPath(p.restaurant!.id.toString()));
        homeKey.currentState?._fetchCart();
      },
      child: Container(
        width: 158,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.28),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: p.image ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(
                        color: accent,
                        child: const Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Price badge top-right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _T.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p.price ?? '',
                    style: const TextStyle(
                      fontFamily: _T.font,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Text(
                    p.name ?? '',
                    maxLines: 2,
                    style: const TextStyle(
                      fontFamily: _T.font,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RESTAURANT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _RestaurantCard extends StatefulWidget {
  final Restaurant r;

  const _RestaurantCard({required this.r});

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard> {
  bool _saved = false;

  Color get _ratingColor {
    final v = double.tryParse(widget.r.rating?.average?.toString() ?? '0') ?? 0;
    if (v >= 4.5) return const Color(0xFF2E7D32);
    if (v >= 4.0) return const Color(0xFF558B2F);
    if (v >= 3.5) return const Color(0xFFF9A825);
    return const Color(0xFFB71C1C);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return GestureDetector(
      onTap: () async {
        final GlobalKey<_HomeScreenState> homeKey = GlobalKey();

        await context.push(AppRoutes.restaurantDetailPath(r.id.toString()));
        homeKey.currentState?._fetchCart();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
                  child: CachedNetworkImage(
                    imageUrl: r.image ?? '',
                    height: kIsWeb ? 450 : 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(
                          height: 155,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.restaurant,
                                size: 40, color: Colors.grey),
                          ),
                        ),
                  ),
                ),
                // Closed overlay
                if (r.isAcceptingOrders == false)
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                    child: Container(
                      height: 155,
                      color: Colors.black.withOpacity(0.58),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                color: Colors.white54, size: 28),
                            SizedBox(height: 6),
                            Text('Currently Closed',
                                style: TextStyle(
                                  fontFamily: _T.font,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Save btn
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _saved = !_saved),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _saved
                            ? _T.primary.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Icon(
                        _saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _saved ? Colors.white : Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Rating badge (top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: _ratingColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          r.rating?.average?.toString() ?? '—',
                          style: const TextStyle(
                            fontFamily: _T.font,
                            fontSize: 12,
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

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.businessName ?? '',
                    style: const TextStyle(
                      fontFamily: _T.font,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _T.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.address ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _T.font,
                      fontSize: 12,
                      color: _T.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chip row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        Icons.access_time_rounded,
                        r.distance?.toString() ?? '',
                        const Color(0xFF1565C0),
                      ),
                      _Chip(
                        Icons.delivery_dining_rounded,
                        r.deliveryFee ?? '',
                        (r.deliveryFee?.startsWith('Free') == true)
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF5D4037),
                      ),
                      if (r.isAcceptingOrders == true)
                        _Chip(Icons.circle, 'Open now', const Color(0xFF2E7D32))
                      else
                        _Chip(Icons.circle, 'Closed', const Color(0xFFB71C1C)),
                    ],
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final isStatus = icon == Icons.circle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isStatus
              ? Container(
            width: 6,
            height: 6,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: color),
          )
              : Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: _T.font,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION HEADING
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final String title;
  final String? sub;
  final Widget? trailing;

  const _SectionHeading({required this.title, this.sub, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: _T.font,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _T.ink,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    style: const TextStyle(
                      fontFamily: _T.font,
                      fontSize: 12,
                      color: _T.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _C {
  static const bg = Color(0xFFF5F5F5);
  static const ink = Color(0xFF1A1A2E);
  static const muted = Color(0xFF9E9E9E);
  static const primary = Color(0xFFFF5722); // deep-orange accent
  static const surface = Colors.white;
  static const font = 'Poppins'; // add to pubspec if not present
}

// ── Algorithm: score = order_count * recency + rating_boost ──
// Since the API just returns a flat list, we rank by a simple
// composite heuristic you can plug real signals into later.
List<PopularFood> _rankPopularFoods(List<PopularFood> raw) {
  // Assign a pseudo-score: items with a price parse correctly score higher,
  // ties broken by list position (server already sorts by popularity).
  double _score(PopularFood f, int idx) {
    final price =
        double.tryParse(f.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
    // Cheap & well-known items (lower price) bubble up; recency = 1/(idx+1)
    final recency = 1.0 / (idx + 1);
    return (price > 0 ? 1 / price : 0) * 0.4 + recency * 0.6;
  }

  final indexed = raw
      .asMap()
      .entries
      .toList();
  indexed
      .sort((a, b) => _score(b.value, b.key).compareTo(_score(a.value, a.key)));
  return indexed.map((e) => e.value).toList();
}

// ── Main section widget ──────────────────────────────────────
class PopularFoodSection extends StatelessWidget {
  final List<PopularFood> foods;

  const PopularFoodSection({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    final ranked = _rankPopularFoods(foods);
    if (ranked.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              // Flame badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Popular Right Now',
                style: TextStyle(
                  fontFamily: _C.font,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _C.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              // const Text(
              //   'See all',
              //   style: TextStyle(
              //     fontFamily: _C.font,
              //     fontSize: 13,
              //     fontWeight: FontWeight.w600,
              //     color: _C.primary,
              //   ),
              // ),
            ],
          ),
        ),

        // ── Horizontal card list ──
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: ranked.length,
            itemBuilder: (context, i) =>
                _PopularFoodCard(
                  food: ranked[i],
                  rank: i,
                ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Individual card ──────────────────────────────────────────
class _PopularFoodCard extends StatefulWidget {
  final PopularFood food;
  final int rank;

  const _PopularFoodCard({required this.food, required this.rank});

  @override
  State<_PopularFoodCard> createState() => _PopularFoodCardState();
}

class _PopularFoodCardState extends State<_PopularFoodCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.93,
      upperBound: 1.0,
    )
      ..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();

  void _onTapUp(_) => _ctrl.forward();

  void _onTapCancel() => _ctrl.forward();

  // Gradient per rank so each card feels unique
  static const _gradients = [
    [Color(0xFFFF5722), Color(0xFFFF9800)], // 🔥 hot orange
    [Color(0xFF7B1FA2), Color(0xFFE91E63)], // purple-pink
    [Color(0xFF0288D1), Color(0xFF00BCD4)], // sky-teal
    [Color(0xFF2E7D32), Color(0xFF8BC34A)], // forest-lime
    [Color(0xFFF57F17), Color(0xFFFFEE58)], // amber-yellow
  ];

  List<Color> get _grad => _gradients[widget.rank % _gradients.length];

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    final isTop3 = widget.rank < 3;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () async {
        final GlobalKey<_HomeScreenState> homeKey = GlobalKey();

        await context.push(AppRoutes.restaurantDetailPath(
          widget.food.restaurant!.id.toString(),
        ));
        homeKey.currentState?._fetchCart();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 155,
          margin: const EdgeInsets.only(right: 12, bottom: 4),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _grad.first.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image area ──
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: f.image ?? '',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _grad,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restaurant_menu_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 36,
                              ),
                            ),
                          ),
                    ),
                  ),

                  // Gradient scrim at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Rank badge (top-left) – only #1, #2, #3
                  if (isTop3)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _grad,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _grad.first.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '#${widget.rank + 1}',
                            style: const TextStyle(
                              fontFamily: _C.font,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Like btn (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _liked = !_liked),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _liked
                              ? _C.primary.withOpacity(0.9)
                              : Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _liked ? Colors.white : Colors.grey.shade400,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Info ──
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _C.font,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (f.restaurant?.name != null)
                      Text(
                        f.restaurant!.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _C.font,
                          fontSize: 10,
                          color: _C.muted,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Price pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _grad,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f.price ?? '—',
                            style: const TextStyle(
                              fontFamily: _C.font,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Category dot label
                        if (f.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _C.bg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              f.category!,
                              style: const TextStyle(
                                fontFamily: _C.font,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _C.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cart Bottom Bar ───────────────────────────────────────────────────────────
//  A sticky floating cart bar that appears at the bottom of restaurant/menu pages
// ─────────────────────────────────────────────────────────────────────────────

class CartBottomBar extends StatefulWidget {
  final res.Restaurant restaurant;
  final int count;
  final bool cardLoad;
  final double total;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const CartBottomBar({
    super.key,
    required this.restaurant,
    required this.cardLoad,
    required this.count,
    required this.total,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<CartBottomBar> createState() => _CartBottomBarState();
}

class _CartBottomBarState extends State<CartBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  // Press-in scale
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    _pressed = widget.cardLoad;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Left: restaurant image + name + count ──────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Restaurant thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: widget.restaurant.restaurantImage ?? '',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                            ),
                          ),
                          // Count badge
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFFF5722), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.count}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF5722),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Name + item count
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.businessName ?? 'Your Cart',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.count} item${widget.count > 1
                                ? 's'
                                : ''}  •  ₹${widget.total.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Right: View Cart CTA ───────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Cart',
                            style: TextStyle(
                              color: Color(0xFFFF5722),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFFFF5722),
                            size: 11,
                          ),
                        ],
                      ),
                    ),

                    // ── Dismiss ────────────────────────────────────────────
                    GestureDetector(
                      onTap: _dismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 12, 10),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
