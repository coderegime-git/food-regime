// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/constants.dart';

/// Centralized typography styles using the Poppins font family.
class AppTextStyles {
  AppTextStyles._();

  static const String _font = AssetConstants.fontPoppins;

  // ─── Display ───────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
  );

  // ─── Headlines ─────────────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Titles ────────────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ─── Body ──────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Labels ────────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ─── Specialized ───────────────────────────────────────────────────────────
  static const TextStyle price = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static const TextStyle priceLarge = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey500,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle tag = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
}
