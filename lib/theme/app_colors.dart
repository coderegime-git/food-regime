// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Brand and semantic color palette for FoodieGo.
class AppColors {
  AppColors._();

  // ─── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C5A);
  static const Color primaryDark = Color(0xFFD94F1A);
  static const Color primarySurface = Color(0xFFFFF0EB); // Tinted bg

  static const Color secondary = Color(0xFF1A1A2E); // Deep navy
  static const Color secondaryLight = Color(0xFF2D2D4A);
  static const Color secondaryDark = Color(0xFF0D0D1A);

  static const Color accent = Color(0xFF4CAF50); // Green (success/veg)
  static const Color accentAmber = Color(0xFFFFC107); // Amber (ratings/spicy)

  // ─── Neutral Palette ───────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ─── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── Light Theme Surfaces ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F0);
  static const Color lightBorder = Color(0xFFE8E8E8);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  static const Color lightTextDisabled = Color(0xFFAAAAAA);

  // ─── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0E0E1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkBorder = Color(0xFF2E2E4A);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextDisabled = Color(0xFF666680);

  // ─── Food Category Colors ──────────────────────────────────────────────────
  static const Color categoryBurger = Color(0xFFFF8A65);
  static const Color categoryPizza = Color(0xFFFFCC02);
  static const Color categorySushi = Color(0xFF80DEEA);
  static const Color categorySalad = Color(0xFFA5D6A7);
  static const Color categoryDessert = Color(0xFFF48FB1);
  static const Color categoryDrinks = Color(0xFF90CAF9);
  static const Color categoryNoodles = Color(0xFFFFCC80);
  static const Color categoryBiryani = Color(0xFFBCAAA4);

  // ─── Rating Colors ─────────────────────────────────────────────────────────
  static const Color ratingExcellent = Color(0xFF2E7D32);
  static const Color ratingGood = Color(0xFF558B2F);
  static const Color ratingAverage = Color(0xFFF9A825);
  static const Color ratingPoor = Color(0xFFB71C1C);

  // ─── Status Colors ─────────────────────────────────────────────────────────
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusConfirmed = Color(0xFF2196F3);
  static const Color statusPreparing = Color(0xFFFF9800);
  static const Color statusOnTheWay = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  // ─── Gradient Presets ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
