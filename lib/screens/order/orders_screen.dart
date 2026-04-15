// lib/screens/order/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/model/order_history_data.dart';
import 'package:food_delivery_app/theme/theme.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../widgets/empty_card.dart';

enum OrderStatus {
  placed,
  accepted,
  rejected,
  ready,
  riderAssigned,
  riderAccepted,
  reachedPickup,
  picked,
  delivered,
  cancelled,
  reachedDelivery,
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _apiService = ApiService();
  final _scrollController = ScrollController();

  // ── Pagination state ───────────────────────────────────────────────────────
  final List<Results> _allOrders = [];
  int _currentPage = 1;
  bool _hasMore = true; // true while `next` URL exists in API response
  bool _initialLoading = true;
  bool _paginationLoading = false;

  // ── Filter ─────────────────────────────────────────────────────────────────
  String _filter = 'all';

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Results> get _filtered {
    switch (_filter) {
      case 'delivered':
        return _allOrders.where((o) => o.status == 'delivered').toList();
      case 'cancelled':
        return _allOrders.where((o) => o.status == 'cancelled').toList();
      default:
        return List.from(_allOrders);
    }
  }

  double get _totalSpent => _allOrders
      .where((o) => o.status == 'delivered')
      .fold(0.0, (s, o) => s + (num.tryParse(o.totalAmount.toString()) ?? 0))
      .toDouble();

  int get _deliveredCount =>
      _allOrders.where((o) => o.status == 'delivered').length;

  int get _cancelledCount =>
      _allOrders.where((o) => o.status == 'cancelled').length;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchPage(1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll listener – load next page near bottom ───────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // ── Fetch helpers ──────────────────────────────────────────────────────────

  Future<void> _fetchPage(int page) async {
    if (page == 1) {
      setState(() {
        if (_paginationLoading == true) {
          _initialLoading = false;
        }
        _allOrders.clear();
        _hasMore = true;
      });
    }

    try {
      final res = await _apiService.getOrderHistory(
          pageNo: page.toString(), status: _filter);
      final newResults = res.data?.results ?? [];
      final nextUrl = res.data?.next; // null when no more pages

      setState(() {
        _currentPage = page;
        _allOrders.addAll(newResults);
        _hasMore = nextUrl != null;
        _initialLoading = false;
        _paginationLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _paginationLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_paginationLoading || !_hasMore) return;
    setState(() => _paginationLoading = true);
    await _fetchPage(_currentPage + 1);
  }

  Future<void> _refresh(page) => _fetchPage(page);

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _initialLoading
            ? Center(
                child: AppDefaultLoader(
                color: AppColors.primary,
                loading: _initialLoading,
              ))
            : Column(
                children: [
                  _buildHeader(),
                  _buildFilterBar(),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _refresh(1),
                      child: _buildList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.of(context).pop(),
                  //   child: Container(
                  //     width: 38,
                  //     height: 38,
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFFF5F5F5),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: const Icon(Icons.arrow_back_ios_new_rounded,
                  //         size: 16, color: Color(0xFF0F0F0F)),
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR ORDERS',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: Colors.grey[400],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Total spent
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL SPENT',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.4,
                      color: Colors.grey[400],
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${_totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick stats row
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final avgOrder = _deliveredCount > 0 ? _totalSpent / _deliveredCount : 0.0;
    final items = [
      ('🛍️', '${_allOrders.length}', 'Orders'),
      ('✅', '$_deliveredCount', 'Delivered'),
      ('❌', '$_cancelledCount', 'Cancelled'),
      ('💸', '₹${avgOrder.toStringAsFixed(0)}', 'Avg. Order'),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F0F0F),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  item.$3,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Filter bar ─────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final filters = [
      ('all', 'All', '${_allOrders.length}'),
      ('delivered', 'Delivered', '$_deliveredCount'),
      ('cancelled', 'Cancelled', '$_cancelledCount'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: filters.map((f) {
          final isActive = _filter == f.$1;
          return GestureDetector(
            onTap: () => setState(() {
              _filter = f.$1;
              _currentPage = 1;
              _paginationLoading = true;
              _refresh(_currentPage);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0F0F0F)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      f.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.grey[500],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Order list ─────────────────────────────────────────────────────────────

  Widget _buildList() {
    final orders = _filtered;

    if (orders.isEmpty && !_paginationLoading) {
      return EmptyState.noOrders(
        onAction: () => context.go(AppRoutes.home),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: orders.length + 1, // +1 for bottom loader / end indicator
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return _buildBottomIndicator();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderCard(
            order: orders[index],
            onTap: () async {
              await context.push(
                AppRoutes.orderDetailPath(orders[index].id.toString()),
              );
              // Refresh to pick up any status changes
              // await _refresh(_currentPage);
            },
          ),
        );
      },
    );
  }

  // ── Bottom loader / end indicator ──────────────────────────────────────────

  Widget _buildBottomIndicator() {
    if (_paginationLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: AppDefaultLoader(
                color: AppColors.primary, loading: _paginationLoading),
          ),
        ),
      );
    }

    if (!_hasMore && _allOrders.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "You've seen all ${_allOrders.length} orders",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
          ],
        ),
      );
    }

    return const SizedBox(height: 16);
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    String emoji, title, subtitle;
    switch (_filter) {
      case 'delivered':
        emoji = '📦';
        title = 'No deliveries yet';
        subtitle = 'Your delivered orders will appear here';
        break;
      case 'cancelled':
        emoji = '🚫';
        title = 'No cancellations';
        subtitle = 'Great! You haven\'t cancelled any orders';
        break;
      default:
        emoji = '🍽️';
        title = 'No orders yet';
        subtitle = 'Your order history will appear here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F0F0F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _OrderCard
// ═════════════════════════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final Results order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  // Status config
  static const _statusConfig = {
    'delivered': {
      'emoji': '✅',
      'label': 'Delivered',
      'bg': Color(0xFFE6F9EE),
      'fg': Color(0xFF15803D)
    },
    'cancelled': {
      'emoji': '❌',
      'label': 'Cancelled',
      'bg': Color(0xFFFFEEEE),
      'fg': Color(0xFFDC2626)
    },
    'pending': {
      'emoji': '⏳',
      'label': 'Pending',
      'bg': Color(0xFFFFF7E6),
      'fg': Color(0xFFD97706)
    },
    'preparing': {
      'emoji': '👨‍🍳',
      'label': 'Preparing',
      'bg': Color(0xFFFFF7E6),
      'fg': Color(0xFFD97706)
    },
    'on_the_way': {
      'emoji': '🛵',
      'label': 'On the way',
      'bg': Color(0xFFE8F0FE),
      'fg': Color(0xFF1D4ED8)
    },
  };

  Map<String, dynamic> get _status {
    return _statusConfig[order.status] ??
        {
          'emoji': '📋',
          'label': order.status ?? 'Unknown',
          'bg': const Color(0xFFF5F5F5),
          'fg': Colors.grey
        };
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _status;
    final items = order;
    final itemSummary = items.orderNumber;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  // Restaurant icon placeholder
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: order.restaurantImage != null
                          ? Image.network(
                              order.restaurantImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Text('🍽️',
                                      style: TextStyle(fontSize: 20))),
                            )
                          : const Center(
                              child:
                                  Text('🍽️', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName ?? 'Restaurant',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF0F0F0F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          itemSummary.toString(),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cfg['bg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cfg['emoji'] as String,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          cfg['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cfg['fg'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey.shade100),

            // ── Bottom row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Order ID
                  _MetaChip(
                    icon: Icons.receipt_long_outlined,
                    label: '#${order.id}',
                  ),
                  const SizedBox(width: 8),
                  // Date
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(order.createdAt ?? ''),
                  ),
                  const Spacer(),
                  // Amount
                  Text(
                    '₹${order.totalAmount ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey[400]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
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
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Small meta chip ────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
