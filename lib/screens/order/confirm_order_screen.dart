import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../model/cart_data.dart';
import '../../model/home_data.dart' show Coupon;
import '../../model/profile_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/api_service.dart';
import '../../utils/helper.dart';
import '../../utils/sharedpreference_helper.dart';
import '../home/restaurant_detail_screen.dart';
import '../profile/saved_addresses_screen.dart';
import '../../model/restauant_detail_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ConfirmOrderPage  –  redesigned with animated place-order button,
//  3-step placing flow (loading → confirming → success) & premium card UI
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Colour tokens ──────────────────────────────────────────────────────────
const kBg = Color(0xFFF7F3EF);
const kPrimary = Color(0xFFFF5722);
const kPrimaryLight = Color(0xFFFFF0EB);
const kText = Color(0xFF1A1A1A);
const kSubText = Color(0xFF6B6B6B);
const kCard = Colors.white;
const kGreen = Color(0xFF15803D);
const kGreenBg = Color(0xFFE6F9EE);

// ─────────────────────────────────────────────────────────────────────────────

class ConfirmOrderPage extends StatefulWidget {
  final Restaurant restaurant;
  final CartData cartData;
  final ValueChanged<CartDataItem> onIncrement;
  final ValueChanged<CartDataItem> onDecrement;

  const ConfirmOrderPage({
    super.key,
    required this.restaurant,
    required this.cartData,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage>
    with TickerProviderStateMixin {
  final _apiService = ApiService();

  String _payMethod = 'cod';
  _PlaceState _placeState = _PlaceState.idle;
  String? _orderId;
  String? id;

  CheckoutPreview? _preview;
  bool _loadingPreview = true;

  String? _appliedCoupon;
  bool _useWallet = false;
  ProfileData? _userData;

  // ── Animated button controllers ──────────────────────────────────────────
  late final AnimationController _btnCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _btnWidth; // idle→loading width shrink
  late final Animation<double> _btnScale;
  late final Animation<double> _pulse;

  // ── Success screen controller ─────────────────────────────────────────────
  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _userData = SharedPreferenceHelper.getUserObject();
    _fetchPreview();

    // Button shrink animation (full-width → circle)
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _btnWidth = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
    _btnScale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    // Pulse for the loading circle
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Success pop-in
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successScale =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut)
            as Animation<double>;
    _successFade = CurvedAnimation(parent: _successCtrl, curve: Curves.easeIn)
        as Animation<double>;
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ── Derived getters ───────────────────────────────────────────────────────
  double get _itemsTotal => _preview?.itemsTotal ?? 0;

  double get _deliveryFee => _preview?.deliveryFee ?? 0;

  double get _platformFee => _preview?.platformFee ?? 0;

  double get _discountAmount => _preview?.discountAmount ?? 0;

  double get _walletApplied => _preview?.walletApplied ?? 0;

  double get _subscriptionDiscount => _preview?.subscriptionDiscount ?? 0;

  double get _total => _preview?.totalAmount ?? 0;

  bool get _isFreeDelivery => _preview?.isFreeDelivery ?? false;

  double get _walletBalance => _preview?.walletBalance ?? 0;

  // ── Fetch preview ─────────────────────────────────────────────────────────
  Future<void> _fetchPreview() async {
    setState(() => _loadingPreview = true);
    final res = await _apiService.getCheckoutPreview(
      couponCode: _appliedCoupon,
      useWallet: _useWallet,
    );
    if (res['statusCode'] == 1 && res['data'] != null) {
      setState(() {
        _preview = CheckoutPreview.fromJson(res['data']);
        _loadingPreview = false;
      });
    } else {
      setState(() => _loadingPreview = false);
    }
  }

  // ── Place order with animated 3-step flow ─────────────────────────────────
  Future<void> _placeOrder() async {
    if (_placeState != _PlaceState.idle) return;
    if (_userData?.data == null) return;

    HapticFeedback.mediumImpact();

    // Step 1 – shrink button to spinner
    setState(() => _placeState = _PlaceState.loading);
    await _btnCtrl.forward();

    try {
      // Step 2 – API call (min 2 s so animation is visible)
      final apiCall = _apiService.placeOrder(
        deliveryAddressId: _userData!.data!.defaultAddress!.id.toString(),
        paymentMethod: _payMethod,
        couponCode: _appliedCoupon ?? '',
        useWallet: _useWallet,
      );
      final delay = Future.delayed(const Duration(milliseconds: 2200));
      final results = await Future.wait([apiCall, delay]);
      final res = results[0] as Map<String, dynamic>;

      if (res['statusCode'] == 1) {
        await _apiService.removeAllCart();

        // Step 3 – confirming flash
        setState(() => _placeState = _PlaceState.confirming);
        await Future.delayed(const Duration(milliseconds: 700));

        HapticFeedback.heavyImpact();
        setState(() {
          print(res);
          _placeState = _PlaceState.success;
          _orderId = res['data']['order_number'].toString();
          id = res['data']['order_id'].toString();
        });
        _successCtrl.forward();
      } else {
        await _btnCtrl.reverse();
        setState(() => _placeState = _PlaceState.idle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message'] ?? 'Order failed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    } catch (_) {
      await _btnCtrl.reverse();
      setState(() => _placeState = _PlaceState.idle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order failed. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _openCouponPage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CouponPage(
          orderTotal: _itemsTotal,
          appliedCouponCode: _appliedCoupon,
          onCouponApplied: (code) {
            setState(() => _appliedCoupon = code.isEmpty ? null : code);
            _fetchPreview();
          },
        ),
      ),
    );
    if (result != null) {
      setState(() => _appliedCoupon = result.isEmpty ? null : result);
      _fetchPreview();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_placeState == _PlaceState.success && _orderId != null) {
      return _OrderSuccessScreen(
        orderId: _orderId!,
        id: id!,
        scaleAnim: _successScale,
        fadeAnim: _successFade,
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: _loadingPreview && _preview == null
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2))
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildRestaurantHeader(),
                      const SizedBox(height: 14),
                      _buildCartItems(),
                      const SizedBox(height: 14),
                      if (_isFreeDelivery) _buildFreeDeliveryBanner(),
                      _buildDeliverySection(),
                      const SizedBox(height: 14),
                      _buildCouponSection(),
                      const SizedBox(height: 14),
                      if (_walletBalance > 0) _buildWalletSection(),
                      if (_walletBalance > 0) const SizedBox(height: 14),
                      _buildPaymentSection(),
                      const SizedBox(height: 14),
                      _buildBillSection(),
                    ]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar:
          SingleChildScrollView(child: SafeArea(child: _buildPlaceOrderBar())),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      shadowColor: Colors.grey.shade200,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kText, size: 16),
        ),
      ),
      backgroundColor: kBg,
      elevation: 0,
      foregroundColor: kText,
      title: const Text(
        'Confirm Order',
        style:
            TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: kText),
      ),
    );
  }

  // ── Restaurant header chip ────────────────────────────────────────────────

  Widget _buildRestaurantHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF8A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurant.businessName ?? 'Restaurant',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.restaurant.address ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.cartData.items?.length ?? 0} items',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart items ────────────────────────────────────────────────────────────

  Widget _buildCartItems() {
    final items = _preview?.items ?? widget.cartData.items ?? [];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: '🛒', text: 'Your Items'),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) => Column(
                children: [
                  _ConfirmCartRow(
                    item: e.value,
                    onInc: () async {
                      widget.onIncrement(e.value);
                      await Future.delayed(const Duration(seconds: 1));
                      await _fetchPreview();
                    },
                    onDec: () async {
                      widget.onDecrement(e.value);
                      await Future.delayed(const Duration(seconds: 1));
                      await _fetchPreview();
                    },
                  ),
                  if (e.key < items.length - 1)
                    Divider(
                        height: 1, color: Colors.grey.shade100, thickness: 1),
                ],
              )),
        ],
      ),
    );
  }

  // ── Free delivery banner ──────────────────────────────────────────────────

  Widget _buildFreeDeliveryBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: kGreenBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGreen.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Text('🎉', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You get FREE delivery on this order!',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delivery section ──────────────────────────────────────────────────────

  Widget _buildDeliverySection() {
    final addr = _preview?.deliveryAddress;
    final addressType = addr?['address_type'] ??
        _userData?.data?.defaultAddress?.addressType ??
        '';
    final fullAddress = addr?['full_address'] ??
        _userData?.data?.defaultAddress?.fullAddress ??
        '';
    final pincode =
        addr?['pincode'] ?? _userData?.data?.defaultAddress?.pincode ?? '';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SavedAddressesScreen()));
        setState(() => _userData = SharedPreferenceHelper.getUserObject());
        _fetchPreview();
      },
      child: _Card(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Color(0xFF1D6FB8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13),
                      children: [
                        TextSpan(
                            text: 'Delivery at ',
                            style: TextStyle(color: Colors.grey.shade500)),
                        TextSpan(
                            text: addressType,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, color: kText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$fullAddress, $pincode',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Change',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon section ────────────────────────────────────────────────────────

  Widget _buildCouponSection() {
    final hasCoupon = _appliedCoupon != null && _appliedCoupon!.isNotEmpty;
    return GestureDetector(
      onTap: _openCouponPage,
      child: _Card(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasCoupon ? kGreenBg : kPrimaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(hasCoupon ? '🎟️' : '🏷️',
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasCoupon
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(_appliedCoupon!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: kGreen)),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded,
                              color: kGreen, size: 15),
                        ]),
                        Text('You save ₹${_discountAmount.toStringAsFixed(0)}',
                            style:
                                const TextStyle(fontSize: 12, color: kGreen)),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apply Coupon',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: kText)),
                        Text('Save more on your order',
                            style: TextStyle(fontSize: 11, color: kSubText)),
                      ],
                    ),
            ),
            if (hasCoupon)
              GestureDetector(
                onTap: () {
                  setState(() => _appliedCoupon = null);
                  _fetchPreview();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.red, size: 16),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Wallet section ────────────────────────────────────────────────────────

  Widget _buildWalletSection() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Center(child: Text('👛', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet Balance',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kText)),
                Text('₹${_walletBalance.toStringAsFixed(2)} available',
                    style: const TextStyle(fontSize: 12, color: kSubText)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _useWallet,
            activeColor: kPrimary,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _useWallet = v);
              _fetchPreview();
            },
          ),
        ],
      ),
    );
  }

  // ── Payment section ───────────────────────────────────────────────────────

  Widget _buildPaymentSection() {
    final methods = [
      {
        'value': 'cod',
        'label': 'Cash on Delivery',
        'sub': 'Pay when delivered',
        'icon': '💵'
      },
      {
        'value': 'upi',
        'label': 'UPI',
        'sub': 'GPay, PhonePe, Paytm…',
        'icon': '📱'
      },
      {
        'value': 'card',
        'label': 'Debit / Credit Card',
        'sub': 'Visa, Mastercard…',
        'icon': '💳'
      },
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: '💳', text: 'Payment Method'),
          const SizedBox(height: 10),
          ...methods.map((m) {
            final selected = _payMethod == m['value'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _payMethod = m['value']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? kPrimaryLight : const Color(0xFFFAF8F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? kPrimary : Colors.grey.shade200,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(m['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['label']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: selected ? kPrimary : kText)),
                          Text(m['sub']!,
                              style: const TextStyle(
                                  fontSize: 11, color: kSubText)),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? kPrimary : Colors.transparent,
                        border: Border.all(
                          color: selected ? kPrimary : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Bill summary ──────────────────────────────────────────────────────────

  Widget _buildBillSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: '🧾', text: 'Bill Summary'),
          const SizedBox(height: 12),
          _BillRow(label: 'Item total', value: _itemsTotal),
          _BillRow(
              label: 'Delivery fee',
              value: _deliveryFee,
              isFree: _isFreeDelivery),
          _BillRow(
              label: 'Platform fee',
              value: _platformFee,
              isFree: _platformFee == 0),
          if (_discountAmount > 0)
            _BillRow(
              label: 'Coupon (${_appliedCoupon ?? ''})',
              value: -_discountAmount,
              isDiscount: true,
            ),
          if (_walletApplied > 0)
            _BillRow(
                label: 'Wallet applied',
                value: -_walletApplied,
                isDiscount: true),
          if (_subscriptionDiscount > 0)
            _BillRow(
                label: 'Subscription',
                value: -_subscriptionDiscount,
                isDiscount: true),
          const SizedBox(height: 8),
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFDDD0C8),
                  Colors.transparent
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _BillRow(label: 'Grand Total', value: _total, isTotal: true),
          if (_discountAmount > 0 || _walletApplied > 0)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kGreenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('🎊', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'You saved ₹${(_discountAmount + _walletApplied + _subscriptionDiscount).toStringAsFixed(0)} on this order!',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kGreen),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Animated Place Order bar ──────────────────────────────────────────────

  Widget _buildPlaceOrderBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_btnCtrl, _pulseCtrl]),
        builder: (_, __) {
          final isLoading = _placeState == _PlaceState.loading;
          final isConfirming = _placeState == _PlaceState.confirming;

          // Lerp button width: full-width ↔ 54-wide circle
          final screenW = MediaQuery.of(context).size.width - 32; // padding
          final targetW = isLoading || isConfirming ? 54.0 : screenW;
          final currentW = screenW - (screenW - 54) * (1 - _btnWidth.value);

          return Center(
            child: ScaleTransition(
              scale: isLoading ? _pulse : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: _placeState == _PlaceState.idle ? _placeOrder : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: isLoading || isConfirming ? 54 : screenW,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: isConfirming
                        ? const LinearGradient(
                            colors: [kGreen, Color(0xFF22C55E)])
                        : const LinearGradient(
                            colors: [Color(0xFFFF5722), Color(0xFFFF8A50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(
                        isLoading || isConfirming ? 27 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: (isConfirming ? kGreen : kPrimary)
                            .withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        )
                      : isConfirming
                          ? const Center(
                              child: Icon(Icons.check_rounded,
                                  color: Colors.white, size: 26),
                            )
                          : Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Place Order  •  ₹${_total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: kSubText));
}

// ── Place state enum ──────────────────────────────────────────────────────────

enum _PlaceState { idle, loading, confirming, success }

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String icon;
  final String text;

  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
      ],
    );
  }
}

// ── Cart row ──────────────────────────────────────────────────────────────────

class _ConfirmCartRow extends StatelessWidget {
  final CartDataItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _ConfirmCartRow(
      {required this.item, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Food image/icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.image != null
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 22))),
                    )
                  : const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 22))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14, color: kText),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: '₹${item.itemPrice ?? 0} × ${item.quantity}',
                          style:
                              const TextStyle(fontSize: 12, color: kSubText)),
                      TextSpan(
                          text: '  =  ₹${item.subtotal ?? 0}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Stepper(value: item.quantity ?? 0, onInc: onInc, onDec: onDec),
        ],
      ),
    );
  }
}

// ── Stepper ───────────────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _Stepper(
      {required this.value, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, onDec),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Text('$value',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: kPrimary)),
          ),
          _btn(Icons.add_rounded, onInc, filled: true),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback cb, {bool filled = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        cb();
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: filled ? Colors.white : kPrimary),
      ),
    );
  }
}

// ── Card shell ────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 3))
        ],
      ),
      child: child,
    );
  }
}

// ── Bill row ──────────────────────────────────────────────────────────────────

class _BillRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isFree;
  final bool isTotal;
  final bool isDiscount;

  const _BillRow({
    required this.label,
    required this.value,
    this.isFree = false,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color valueColor = isDiscount
        ? kGreen
        : isTotal
            ? kText
            : kSubText;

    String valueText;
    if (isFree && value == 0) {
      valueText = 'FREE';
    } else if (isDiscount) {
      valueText = '− ₹${value.abs().toStringAsFixed(0)}';
    } else {
      valueText = '₹${value.toStringAsFixed(0)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                  color: isTotal ? kText : kSubText),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
                fontSize: isTotal ? 16 : 13,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                color: isFree && value == 0 ? kGreen : valueColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Order Success Screen  –  with pop-in animation
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String id;
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;

  const _OrderSuccessScreen({
    required this.orderId,
    required this.id,
    required this.scaleAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: fadeAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated check circle
                ScaleTransition(
                    scale: scaleAnim,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        /* gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent.shade200,
                            Colors.lightGreen.shade200
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),*/
                      ),
                      child: Container(
                        color: Colors.transparent,
                        child: Lottie.asset('assets/json/success-check.json'),
                      ),
                    )),
                const SizedBox(height: 10),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your food is being prepared 🍳',
                  style: TextStyle(fontSize: 15, color: kSubText),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 12)
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: kPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Order #$orderId',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () async {
                    await context.push(
                      AppRoutes.orderDetailPath(id),
                    );
                  },
                  child: const Text(
                    'Track your order →',
                    style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
