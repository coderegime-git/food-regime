import 'package:flutter/material.dart';
import 'package:food_delivery_app/constants/app_constants.dart';
import 'package:food_delivery_app/theme/app_colors.dart';

import '../screens/home/restaurant_detail_screen.dart';

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  // ── Named presets ──────────────────────────────────────────────────────────

  const EmptyState.noMenu({super.key, this.onAction})
      : emoji = '🍽️',
        title = 'No menu available',
        subtitle = 'This restaurant hasn\'t added\nany items yet.',
        buttonLabel = 'Go back';

  const EmptyState.noResults({super.key, this.onAction})
      : emoji = '🔍',
        title = 'No results found',
        subtitle = 'Try a different search term\nor browse categories.',
        buttonLabel = 'Clear search';

  const EmptyState.noOrders({super.key, this.onAction})
      : emoji = '🛍️',
        title = 'No orders yet',
        subtitle = 'Your order history will\nappear here.',
        buttonLabel = 'Browse restaurants';

  const EmptyState.noCart({super.key, this.onAction})
      : emoji = '🛒',
        title = 'Your cart is empty',
        subtitle = 'Add items from a restaurant\nto get started.',
        buttonLabel = 'Browse menu';

  const EmptyState.noNotifications({super.key, this.onAction})
      : emoji = '🔔',
        title = 'All caught up!',
        subtitle =
            'No notifications yet.\nWe\'ll let you know when something arrives.',
        buttonLabel = null;

  const EmptyState.noAddress({super.key, this.onAction})
      : emoji = '📍',
        title = 'No address saved',
        subtitle = 'Add a delivery address\nto place your order.',
        buttonLabel = 'Add address';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji in a soft circle
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEEEEEE),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 38),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F0F0F),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
                height: 1.6,
              ),
            ),

            // Optional action button
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    buttonLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
