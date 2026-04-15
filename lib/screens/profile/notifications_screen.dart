// ─────────────────────────────────────────────────────────────────────────────
// notification_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:food_delivery_app/model/notification_data.dart';
import 'package:food_delivery_app/utils/api_service.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_loader.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationsScreen> {
  final _apiService = ApiService();

  NotificationData? _notificationData;
  bool _isLoading = true;
  bool _markingAll = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getNotification();
      setState(() => _notificationData = res);
    } catch (_) {
      // handle error if needed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Mark all as read ───────────────────────────────────────────────────────

  Future<void> _markAllAsRead() async {
    if (_markingAll) return;
    final unread = _notificationData?.data?.where((d) => d.isRead == false);
    if (unread == null || unread.isEmpty) return;

    setState(() => _markingAll = true);
    try {
      //await _apiService.markAllNotificationsRead(); // your API call
      // Optimistic update – flip all locally
      for (final n in _notificationData!.data!) {
        n.isRead = true;
      }
      setState(() => _notificationData!.unreadCount = 0);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed. Please try again.')),
      );
    } finally {
      setState(() => _markingAll = false);
    }
  }

  // ── Tap single notification ────────────────────────────────────────────────

  Future<void> _onNotificationTap(Data notification) async {
    if (notification.isRead == false) {
      setState(() => notification.isRead = true);
      try {
        await _apiService.markNotificationRead(
            notificationId: notification.id!);
        final count = _notificationData?.unreadCount ?? 0;
        if (count > 0) {
          setState(() => _notificationData!.unreadCount = count - 1);
        }
      } catch (_) {}
    }
    // Navigate based on type if needed:
    // if (notification.notificationType == 'order_update') { ... }
  }

  // ── Group notifications by date label ─────────────────────────────────────

  Map<String, List<Data>> _grouped(List<Data> items) {
    final Map<String, List<Data>> map = {};
    for (final item in items) {
      final label = _dateLabel(item.createdAt ?? '');
      map.putIfAbsent(label, () => []).add(item);
    }
    return map;
  }

  String _dateLabel(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(date).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return '${diff} days ago';
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
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return 'Earlier';
    }
  }

  String _timeLabel(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $period';
    } catch (_) {
      return '';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: AppDefaultLoader(
                      color: AppColors.primary,
                      loading: _isLoading,
                    ))
                  : _notificationData == null ||
                          (_notificationData!.data?.isEmpty ?? true)
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchNotifications,
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
    final unread = _notificationData?.unreadCount ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F0F0F)),
            ),
          ),
          const SizedBox(width: 12),
          // Title + badge
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F0F0F),
                    letterSpacing: -0.5,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread new',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Mark all as read button
          if (unread > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: _markingAll
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: AppDefaultLoader(
                          color: AppColors.primary,
                          loading: _markingAll,
                        ),
                      )
                    : Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Grouped list ───────────────────────────────────────────────────────────

  Widget _buildList() {
    final all = _notificationData!.data!;
    final grouped = _grouped(all);
    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final label = keys[i];
        final items = grouped[label]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date group header
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: i == 0 ? 0 : 16),
              child: Row(
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.grey[400],
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Divider(color: Colors.grey.shade200, height: 1)),
                ],
              ),
            ),
            ...items.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotificationCard(
                    notification: n,
                    timeLabel: _timeLabel(n.createdAt ?? ''),
                    onTap: () => _onNotificationTap(n),
                  ),
                )),
          ],
        );
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
            ),
            child: const Center(
              child: Text('🔔', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F0F0F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No notifications yet.\nWe\'ll let you know when something arrives.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _NotificationCard
// ═════════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatelessWidget {
  final Data notification;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeLabel,
    required this.onTap,
  });

  // ── Notification type → icon config ────────────────────────────────────────

  static const _typeConfig = {
    'order_update': {
      'emoji': '🛵',
      'bg': Color(0xFFE8F0FE),
      'fg': Color(0xFF1D4ED8)
    },
    'order_placed': {
      'emoji': '🛍️',
      'bg': Color(0xFFE8F0FE),
      'fg': Color(0xFF1D4ED8)
    },
    'delivered': {
      'emoji': '✅',
      'bg': Color(0xFFE6F9EE),
      'fg': Color(0xFF15803D)
    },
    'cancelled': {
      'emoji': '❌',
      'bg': Color(0xFFFFEEEE),
      'fg': Color(0xFFDC2626)
    },
    'promo': {'emoji': '🎁', 'bg': Color(0xFFFFF7E6), 'fg': Color(0xFFD97706)},
    'offer': {'emoji': '🏷️', 'bg': Color(0xFFFFF7E6), 'fg': Color(0xFFD97706)},
    'wallet': {'emoji': '👛', 'bg': Color(0xFFEDE9FE), 'fg': Color(0xFF7C3AED)},
    'payment': {
      'emoji': '💳',
      'bg': Color(0xFFEDE9FE),
      'fg': Color(0xFF7C3AED)
    },
  };

  Map<String, dynamic> get _cfg {
    return _typeConfig[notification.notificationType] ??
        {'emoji': '🔔', 'bg': const Color(0xFFF5F5F5), 'fg': Colors.grey};
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final isUnread = notification.isRead == false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.2)
                : const Color(0xFFEEEEEE),
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cfg['bg'] as Color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(cfg['emoji'] as String,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: const Color(0xFF0F0F0F),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isUnread) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'New',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
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
