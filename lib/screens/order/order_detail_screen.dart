// ── Color Palette ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:food_delivery_app/model/order_detail_data.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:food_delivery_app/widgets/common_textform_field.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../utils/helper.dart';

const kBg = Color(0xFFF7F6F3);
const kSurface = Color(0xFFFFFFFF);
const kSurface2 = Color(0xFFF2F0EB);
const kAccent = Color(0xFFE8521A);
const kAccentLight = Color(0xFFFFF0EB);
const kGreen = Color(0xFF2E7D50);
const kGreenLight = Color(0xFFE8F5EE);
const kOrange = Color(0xFFF59E0B);
const kOrangeLight = Color(0xFFFFF8E6);
const kBlue = Color(0xFF2563EB);
const kBlueLight = Color(0xFFEFF4FF);
const kText = Color(0xFF18120A);
const kTextMid = Color(0xFF6B5E50);
const kTextLight = Color(0xFFAD9E8E);
const kBorder = Color(0xFFEAE6DF);
const kShadow = Color(0x10000000);

// ── Tracking Step Model ───────────────────────────────────────────────────────
class _TrackStep {
  final String label;
  final String? time;
  final bool done;
  final bool active;

  const _TrackStep({
    required this.label,
    this.time,
    required this.done,
    this.active = false,
  });
}

// ── Status Helpers ────────────────────────────────────────────────────────────
String _statusLabel(String status) {
  return switch (status) {
    'placed' => 'Order Placed',
    'accepted' => 'Confirmed',
    'rejected' => 'Order Rejected',
    'ready' => 'Ready for Pickup',
    'rider_assigned' => 'Rider Assigned',
    'rider_accepted' => 'Rider On the Way',
    'reached_pickup' => 'Rider at Restaurant',
    'picked' => 'Out for Delivery',
    'reached_delivery' => 'Rider Near You',
    'delivered' => 'Delivered',
    'cancelled' => 'Cancelled',
    _ => status,
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'delivered' => kGreen,
    'cancelled' || 'rejected' => const Color(0xFFDC2626),
    'placed' => kBlue,
    'reached_delivery' => const Color(0xFF06B6D4),
    'rider_assigned' || 'rider_accepted' => kOrange,
    'reached_pickup' || 'picked' => const Color(0xFFF59E0B),
    _ => kOrange,
  };
}

IconData _statusIcon(String status) {
  return switch (status) {
    'placed' => Icons.receipt_long_rounded,
    'accepted' => Icons.thumb_up_rounded,
    'rejected' => Icons.thumb_down_rounded,
    'ready' => Icons.restaurant_rounded,
    'rider_assigned' => Icons.person_pin_rounded,
    'rider_accepted' => Icons.directions_bike_rounded,
    'reached_pickup' => Icons.store_rounded,
    'picked' => Icons.delivery_dining_rounded,
    'reached_delivery' => Icons.location_on_rounded,
    'delivered' => Icons.check_circle_rounded,
    'cancelled' => Icons.cancel_rounded,
    _ => Icons.hourglass_empty_rounded,
  };
}

Color _statusBgColor(String status) {
  switch (status) {
    case 'delivered':
      return kGreenLight;
    case 'cancelled':
      return const Color(0xFFFFEEEE);
    case 'placed':
      return kBlueLight;
    default:
      return kOrangeLight;
  }
}

String _fmtDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  } catch (_) {
    return iso;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  OrderDetailData? orderDetailData;
  final apiService = ApiService();
  bool isLoading = true;
  bool isLoad = false;
  bool reLoad = false;
  bool _reviewSubmitted = false;

  @override
  void initState() {
    super.initState();
    getOrderDetails();
  }

  getOrderDetails() async {
    try {
      orderDetailData = await apiService.getOrderDetails(widget.orderId);
      _ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 800))
        ..forward();
      setState(() {
        isLoading = false;
      });
      final res = await apiService.getOrderRatings(orderId: widget.orderId);
      if (res['statusCode'] == 1) {
        _reviewSubmitted = true;
        setState(() {});
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _anim(double start, Widget child) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
          ).value;
          return Opacity(
            opacity: t,
            child: Transform.translate(
                offset: Offset(0, 18 * (1 - t)), child: child),
          );
        },
      );

  Future<String?> showCancelOrderSheet(BuildContext context) async {
    final reasonController = TextEditingController();

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cancel Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Enter cancellation reason",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, reasonController.text);
                        },
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

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

    if (orderDetailData == null || orderDetailData!.data == null) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Text("No data available"),
        ),
      );
    }

    final o = orderDetailData!.data!;
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          _anim(0.0, _TopBar(order: o)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                _anim(0.05, _HeroCard(order: o)),
                const SizedBox(height: 14),
                _anim(0.15, _TrackingCard(order: o)),
                const SizedBox(height: 14),
                _anim(0.25, _ItemsCard(order: o)),
                const SizedBox(height: 14),
                _anim(0.35, _BillCard(order: o)),
                const SizedBox(height: 14),
                _anim(0.45, _DeliveryCard(order: o)),
                const SizedBox(height: 20),
                _anim(
                    0.55,
                    _ActionButtons(
                      isLoad: isLoad,
                      reLoad: reLoad,
                      order: o,
                      onTap: () async {
                        if (isLoad) return;

                        final reason = await showCancelOrderSheet(context);

                        print(reason);

                        if (reason == null || reason.isEmpty) return;

                        setState(() {
                          isLoad = true;
                        });

                        final data = await apiService.cancelOrder(o.id, reason);

                        orderDetailData =
                            await apiService.getOrderDetails(widget.orderId);

                        setState(() {
                          isLoad = false;
                        });

                        Helper().showToast(
                          context,
                          data['message'],
                          data['statusCode'],
                        );
                      },
                      reOrderOnTap: () async {
                        if (reLoad) return;

                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Repeat Order"),
                              content: const Text(
                                  "Are you sure you want to repeat this order?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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

                        if (confirm != true) return;

                        // Proceed with cancel
                        setState(() {
                          reLoad = true;
                        });

                        final data = await apiService.repeatOrder(o.id);
                        orderDetailData =
                            await apiService.getOrderDetails(widget.orderId);

                        setState(() {
                          reLoad = false;
                        });

                        Helper().showToast(
                          context,
                          data['message'],
                          data['statusCode'],
                        );
                      },
                    )),
                if (o.status == 'delivered' &&
                    o.status != "cancelled" &&
                    o.status != "rejected") ...[
                  const SizedBox(height: 14),
                  _reviewSubmitted
                      ? const _ReviewSubmittedCard()
                      : _ReviewCard(
                          orderId: o.id ?? 0,
                          apiService: apiService,
                          onSubmitted: () =>
                              setState(() => _reviewSubmitted = true),
                        ),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Data order;

  const _TopBar({required this.order});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        color: kBg,
        child: Row(children: [
          _IBtn(Icons.arrow_back_ios_new_rounded,
              () => Navigator.maybePop(context)),
          Expanded(
              child: Column(children: [
            const Text('Order Details',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kText,
                    letterSpacing: -0.3)),
            Text(order.orderNumber ?? "",
                style: const TextStyle(
                    fontSize: 11,
                    color: kTextLight,
                    fontFamily: 'monospace',
                    letterSpacing: 0.8)),
          ])),
          _IBtn(Icons.ios_share_rounded, () {}),
        ]),
      );
}

class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kBorder),
              boxShadow: const [
                BoxShadow(color: kShadow, blurRadius: 6, offset: Offset(0, 2))
              ]),
          child: Icon(icon, size: 17, color: kText),
        ),
      );
}

// ── Card Shell ────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: const [
              BoxShadow(color: kShadow, blurRadius: 14, offset: Offset(0, 4))
            ]),
        child: child,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _SectionLabel(this.text, {this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: kAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, size: 14, color: kAccent),
            const SizedBox(width: 5),
          ],
          Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kText,
                  letterSpacing: 0.1)),
        ]),
      );
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Data order;

  const _HeroCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status ?? "");
    final statusBg = _statusBgColor(order.status ?? "");

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // ── Top band ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
              color: statusBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Restaurant image
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                  boxShadow: const [
                    BoxShadow(
                        color: kShadow, blurRadius: 8, offset: Offset(0, 3))
                  ]),
              child: GestureDetector(
                onTap: () {
                  // context.push(
                  //   AppRoutes.restaurantDetailPath(order.res.toString()),
                  // );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    order.restaurantImage ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.restaurant_rounded,
                            color: kTextLight, size: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(order.restaurantName ?? "",
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: kText)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_rounded, size: 11, color: kTextMid),
                    const SizedBox(width: 3),
                    Text(order.restaurantPhone ?? "",
                        style: const TextStyle(fontSize: 11, color: kTextMid)),
                  ]),
                  const SizedBox(height: 10),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_statusIcon(order.status ?? ""),
                          size: 11, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(_statusLabel(order.status ?? ""),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ]),
                  ),
                  if (order.preparationTime != 0.0)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: kOrange),
                          const SizedBox(width: 5),
                          Text(
                            '${order.preparationTime} mins',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ])),
          ]),
        ),
        // ── Pills row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _SPill(Icons.calendar_today_rounded, 'DATE',
                _fmtDate(order.createdAt ?? "").split('  ').first),
            Container(width: 1, height: 32, color: kBorder),
            _SPill(Icons.shopping_bag_outlined, 'ITEMS',
                '${order.items!.length} item${order.items!.length > 1 ? 's' : ''}'),
            Container(width: 1, height: 32, color: kBorder),
            _SPill(Icons.payments_outlined, 'PAYMENT',
                order.paymentMethod!.toUpperCase()),
          ]),
        ),
      ]),
    );
  }
}

class _SPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SPill(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 18, color: kAccent),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 8,
                color: kTextLight,
                letterSpacing: 1.2,
                fontFamily: 'monospace')),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: kText)),
      ]);
}

class _TrackingStep {
  final String label;
  final String sublabel;
  final IconData icon;
  final String? time;
  final bool done;
  final bool active;

  const _TrackingStep({
    required this.label,
    required this.sublabel,
    required this.icon,
    this.time,
    required this.done,
    required this.active,
  });
}

// ─── Pipeline ────────────────────────────────────────────────────────────────

const _statusOrder = [
  'placed',
  'accepted',
  'ready',
  'rider_assigned',
  'rider_accepted',
  'reached_pickup',
  'picked',
  'reached_delivery',
  'delivered',
];

const _stepMeta = {
  'placed': (
    label: 'Order Placed',
    sublabel: 'We received your order',
    icon: Icons.receipt_long_rounded,
  ),
  'accepted': (
    label: 'Restaurant Confirmed',
    sublabel: 'Restaurant is preparing your food',
    icon: Icons.thumb_up_rounded,
  ),
  'ready': (
    label: 'Food Ready',
    sublabel: 'Your order is packed and ready',
    icon: Icons.restaurant_rounded,
  ),
  'rider_assigned': (
    label: 'Rider Assigned',
    sublabel: 'A delivery rider has been assigned',
    icon: Icons.person_pin_rounded,
  ),
  'rider_accepted': (
    label: 'Rider On the Way',
    sublabel: 'Rider is heading to the restaurant',
    icon: Icons.directions_bike_rounded,
  ),
  'reached_pickup': (
    label: 'Rider at Restaurant',
    sublabel: 'Rider has reached the restaurant',
    icon: Icons.store_rounded,
  ),
  'picked': (
    label: 'Out for Delivery',
    sublabel: 'Your order is on the way',
    icon: Icons.delivery_dining_rounded,
  ),
  'reached_delivery': (
    label: 'Rider Near You',
    sublabel: 'Rider has reached your location',
    icon: Icons.location_on_rounded,
  ),
  'delivered': (
    label: 'Delivered',
    sublabel: 'Enjoy your meal!',
    icon: Icons.check_circle_rounded,
  ),
};

// ─── Builder ─────────────────────────────────────────────────────────────────

List<_TrackingStep> _buildSteps(Data order) {
  final currentIndex = _statusOrder.indexOf(order.status ?? '');

  return List.generate(_statusOrder.length, (i) {
    final stepStatus = _statusOrder[i];
    final meta = _stepMeta[stepStatus]!;
    final isDone = currentIndex > i;
    final isActive = currentIndex == i;

    return _TrackingStep(
      label: meta.label,
      sublabel: meta.sublabel,
      icon: meta.icon,
      done: isDone,
      active: isActive,
      time: (isDone || isActive) ? _getStepTime(order, stepStatus) : null,
    );
  });
}

String? _getStepTime(Data order, String status) {
  if (status == 'placed' && order.createdAt != null) {
    final dt = DateTime.tryParse(order.createdAt!);
    if (dt != null) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
  }
  return null;
}

class _TrackingCard extends StatelessWidget {
  final Data order;

  const _TrackingCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(order);
    final isCancelled =
        order.status == 'cancelled' || order.status == 'rejected';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Order Tracking', icon: Icons.timeline_rounded),
          const SizedBox(height: 14),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCCCC)),
              ),
              child: Row(
                children: [
                  Icon(
                    order.status == 'rejected'
                        ? Icons.thumb_down_rounded
                        : Icons.cancel_rounded,
                    color: const Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.status == 'rejected'
                          ? 'Your order was rejected by the restaurant.'
                          : 'This order was cancelled.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(steps.length, (i) {
              final s = steps[i];
              final isLast = i == steps.length - 1;
              final dotColor = s.done
                  ? kAccent
                  : s.active
                      ? kAccent
                      : kBorder;
              final lineColor = s.done ? kAccent.withOpacity(0.25) : kBorder;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timeline dot + line ──
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: s.done
                              ? kAccent
                              : s.active
                                  ? kAccentLight
                                  : kSurface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: dotColor, width: 1.5),
                          boxShadow: s.active
                              ? [
                                  BoxShadow(
                                    color: kAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                        child: s.done
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Colors.white)
                            : s.active
                                ? Icon(s.icon, size: 15, color: kAccent)
                                : Icon(s.icon, size: 15, color: kTextLight),
                      ),
                      if (!isLast)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 2,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: lineColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // ── Label + time ──
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label + sublabel
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: s.done || s.active
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color:
                                        s.done || s.active ? kText : kTextLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.active ? 'In progress...' : s.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: s.active ? kAccent : kTextLight,
                                    fontStyle: s.active
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Time / Pending badge
                          if (s.time != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.done ? kAccentLight : kSurface2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.time!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: s.done ? kAccent : kTextLight,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            )
                          else if (!s.done)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: kSurface2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: kTextLight,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ── Items Card ────────────────────────────────────────────────────────────────
class _ItemsCard extends StatelessWidget {
  final Data order;

  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SectionLabel('Items Ordered', icon: Icons.fastfood_rounded),
          ...List.generate(order.items!.length, (i) {
            final item = order.items![i];
            final isLast = i == order.items!.length - 1;
            return Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(13)),
                    child: Stack(children: [
                      const Center(
                          child: Icon(Icons.lunch_dining_rounded,
                              color: kTextMid, size: 24)),
                      if (item.quantity! > 1)
                        Positioned(
                            right: 3,
                            bottom: 3,
                            child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                    color: kAccent, shape: BoxShape.circle),
                                child: Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)))),
                    ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.itemName ?? "",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kText)),
                      const SizedBox(height: 3),
                      Text('₹${item.itemPrice} × ${item.quantity}',
                          style:
                              const TextStyle(fontSize: 11, color: kTextMid)),
                    ])),
                Text('₹${item.subtotal}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kText,
                        fontFamily: 'monospace')),
              ]),
              if (!isLast) ...[
                const SizedBox(height: 12),
                const Divider(color: kBorder, height: 1),
                const SizedBox(height: 12)
              ],
            ]);
          }),
        ]),
      );
}

// ── Bill Card ─────────────────────────────────────────────────────────────────
class _BillCard extends StatelessWidget {
  final Data order;

  const _BillCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final deliveryFeeVal = double.tryParse(order.deliveryFee ?? "") ?? 0;
    final platformFeeVal = double.tryParse(order.platformFee ?? "") ?? 0;
    final isFreeDelivery = deliveryFeeVal == 0;
    final isFreePlatform = platformFeeVal == 0;

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionLabel('Price Breakdown', icon: Icons.receipt_rounded),
        _BillRow('Items Total', '₹${order.itemsTotal}'),
        const SizedBox(height: 10),
        _BillRow(
          'Delivery Fee',
          isFreeDelivery ? 'FREE' : '₹${order.deliveryFee}',
          vc: isFreeDelivery ? kGreen : null,
        ),
        const SizedBox(height: 10),
        _BillRow(
          'Platform Fee',
          isFreePlatform ? 'FREE' : '₹${order.platformFee}',
          vc: isFreePlatform ? kGreen : null,
        ),
        const SizedBox(height: 16),
        Container(
            height: 1,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kBg, kBorder, kBg]))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Paid',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
                color: kAccent, borderRadius: BorderRadius.circular(12)),
            child: Text('₹${order.totalAmount}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    fontFamily: 'monospace')),
          ),
        ]),
        const SizedBox(height: 14),
        // Payment method chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: kSurface2, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(color: kShadow, blurRadius: 4)
                    ]),
                child: Icon(
                  order.paymentMethod!.toLowerCase() == 'cod'
                      ? Icons.money_rounded
                      : Icons.credit_card_rounded,
                  size: 16,
                  color: kTextMid,
                )),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      order.paymentMethod!.toUpperCase() == 'COD'
                          ? 'Cash on Delivery'
                          : order.paymentMethod!.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kText)),
                  const Text('Payment Method',
                      style: TextStyle(fontSize: 10, color: kTextLight)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color:
                      order.status == 'delivered' ? kGreenLight : kOrangeLight,
                  borderRadius: BorderRadius.circular(7)),
              child: Text(order.status == 'delivered' ? 'PAID' : 'PENDING',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: order.status == 'delivered' ? kGreen : kOrange,
                      letterSpacing: 1.2,
                      fontFamily: 'monospace')),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String l, v;
  final Color? vc, lc;

  const _BillRow(this.l, this.v, {this.vc, this.lc});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: 13, color: lc ?? kTextMid)),
          Text(v,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: vc ?? kText,
                  fontFamily: 'monospace')),
        ],
      );
}

// ── Delivery Card ─────────────────────────────────────────────────────────────
class _DeliveryCard extends StatelessWidget {
  final Data order;

  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SectionLabel('Delivery Info', icon: Icons.location_on_rounded),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: kAccentLight,
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.location_on_rounded,
                    color: kAccent, size: 22)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Delivering to',
                      style: TextStyle(
                          fontSize: 10,
                          color: kTextLight,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 4),
                  Text(order.deliveryAddress ?? "",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kText)),
                  Text('Pincode: ${order.deliveryPincode}',
                      style: const TextStyle(fontSize: 12, color: kTextMid)),
                ])),
          ]),
          const SizedBox(height: 14),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 14),
          Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: kSurface2, borderRadius: BorderRadius.circular(13)),
                child:
                    const Icon(Icons.phone_rounded, color: kTextMid, size: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Customer Phone',
                      style: TextStyle(
                          fontSize: 10,
                          color: kTextLight,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 4),
                  Text(order.customerPhone ?? "",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kText,
                          fontFamily: 'monospace')),
                ])),
            const _ContactBtn(Icons.call_rounded),
          ]),
        ]),
      );
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;

  const _ContactBtn(this.icon);

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: kAccentLight, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: kAccent, size: 18),
      );
}

// ── Action Buttons ────────────────────────────────────────────────────────────
class _ActionButtons extends StatefulWidget {
  final Data order;
  final VoidCallback onTap;
  final VoidCallback reOrderOnTap;
  final bool isLoad;
  final bool reLoad;

  const _ActionButtons(
      {required this.order,
      required this.onTap,
      required this.isLoad,
      required this.reLoad,
      required this.reOrderOnTap});

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  final apiService = ApiService();
  bool isLoad = false;
  bool reLoad = false;

  @override
  Widget build(BuildContext context) {
    final canReorder = widget.order.status == 'delivered';
    final canCancel = widget.order.status == 'placed';
    isLoad = widget.isLoad;
    reLoad = widget.reLoad;
    return Column(children: [
      if (canReorder) ...[
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: widget.reOrderOnTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: reLoad
                ? AppDefaultLoader(
                    loading: reLoad,
                    color: const Color(0xFFDC2626),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.replay_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Reorder Everything',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                      ]),
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (canCancel) ...[
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: isLoad
                ? AppDefaultLoader(
                    loading: isLoad,
                    color: const Color(0xFFDC2626),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.cancel_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Cancel Order',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                      ]),
          ),
        ),
        const SizedBox(height: 10),
      ],
      SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          onPressed: () {
            context.push(AppRoutes.staticPagePath("faq"));
          },
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBorder, width: 1.5),
              foregroundColor: kTextMid,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.help_outline_rounded, size: 18),
            SizedBox(width: 8),
            Text('Get Help with Order',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2)),
          ]),
        ),
      ),
    ]);
  }
}
// ─── Rating Bar Helper ────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const _StarRating({
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Rating Label ─────────────────────────────────────────────────────────────

String _ratingLabel(int rating) => switch (rating) {
      1 => '😞 Poor',
      2 => '😕 Fair',
      3 => '😊 Good',
      4 => '😄 Great',
      5 => '🤩 Excellent!',
      _ => '',
    };

// ─── Review Card ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatefulWidget {
  final int orderId;
  final ApiService apiService;
  final VoidCallback onSubmitted;

  const _ReviewCard({
    required this.orderId,
    required this.apiService,
    required this.onSubmitted,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  int _restaurantRating = 0;
  int _riderRating = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation
    if (_restaurantRating == 0 || _riderRating == 0) {
      setState(() => _error = 'Please rate both the restaurant and rider.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.apiService.submitReview(
        orderId: widget.orderId.toString(),
        restaurantRating: _restaurantRating.toString(),
        riderRating: _riderRating.toString(),
        review: _reviewCtrl.text.trim(),
      );
      widget.onSubmitted();
    } catch (e) {
      setState(() => _error = 'Failed to submit review. Please try again.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          const _SectionLabel('Rate Your Experience', icon: Icons.star_rounded),
          const SizedBox(height: 16),

          // ── Restaurant Rating ──
          _RatingRow(
            emoji: '🍽️',
            title: 'Restaurant',
            subtitle: 'Food quality & packaging',
            rating: _restaurantRating,
            onChanged: (v) => setState(() => _restaurantRating = v),
          ),
          const SizedBox(height: 16),

          // ── Rider Rating ──
          _RatingRow(
            emoji: '🛵',
            title: 'Delivery Rider',
            subtitle: 'Speed & behaviour',
            rating: _riderRating,
            onChanged: (v) => setState(() => _riderRating = v),
          ),
          const SizedBox(height: 18),

          // ── Review Text ──
          Container(
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: AppTextField(
              ctrl: _reviewCtrl,
              maxLine: 3,
              hint: 'Write your review (optional)...',
            ),
          ),
          const SizedBox(height: 6),

          // ── Error ──
          if (_error != null) ...[
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: Color(0xFFDC2626)),
                const SizedBox(width: 6),
                Text(
                  _error!,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                disabledBackgroundColor: kAccent.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rating Row ───────────────────────────────────────────────────────────────

class _RatingRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final int rating;
  final ValueChanged<int> onChanged;

  const _RatingRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rating > 0 ? kAccent.withOpacity(0.3) : kBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: kTextLight),
                  ),
                ],
              ),
              const Spacer(),
              // Rating label
              if (rating > 0)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _ratingLabel(rating),
                    key: ValueKey(rating),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _StarRating(value: rating, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Submitted State ──────────────────────────────────────────────────────────

class _ReviewSubmittedCard extends StatelessWidget {
  const _ReviewSubmittedCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: kAccentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: kAccent, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'Review Submitted!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thank you for your feedback',
            style: TextStyle(fontSize: 13, color: kTextLight),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
