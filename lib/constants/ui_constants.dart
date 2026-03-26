// lib/constants/ui_constants.dart
import 'package:flutter/material.dart';

/// UI-related constants: spacing, radius, shadow, breakpoints.
class UIConstants {
  UIConstants._();

  // ─── Spacing ───────────────────────────────────────────────────────────────
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  static const double space3XL = 32.0;
  static const double space4XL = 40.0;
  static const double space5XL = 48.0;
  static const double space6XL = 64.0;

  // ─── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 100.0;

  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ─── Icon Sizes ────────────────────────────────────────────────────────────
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // ─── Button Sizes ──────────────────────────────────────────────────────────
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;
  static const double buttonHeightXL = 60.0;
  static const double buttonMinWidth = 120.0;

  // ─── Card ──────────────────────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;
  static const EdgeInsets cardPadding =
  EdgeInsets.all(spaceLG);
  static const EdgeInsets cardPaddingCompact =
  EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD);

  // ─── AppBar ────────────────────────────────────────────────────────────────
  static const double appBarHeight = 60.0;
  static const EdgeInsets appBarPadding =
  EdgeInsets.symmetric(horizontal: spaceLG);

  // ─── Bottom Navigation ─────────────────────────────────────────────────────
  static const double bottomNavHeight = 70.0;

  // ─── Page Padding ──────────────────────────────────────────────────────────
  static const EdgeInsets pagePadding =
  EdgeInsets.all(spaceLG);
  static const EdgeInsets pageHorizontalPadding =
  EdgeInsets.symmetric(horizontal: spaceLG);
  static const EdgeInsets pageVerticalPadding =
  EdgeInsets.symmetric(vertical: spaceLG);

  // ─── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Breakpoints ───────────────────────────────────────────────────────────
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // ─── Divider ───────────────────────────────────────────────────────────────
  static const double dividerThickness = 1.0;
  static const double dividerThickBold = 2.0;

  // ─── Input Fields ──────────────────────────────────────────────────────────
  static const double inputHeight = 52.0;
  static const EdgeInsets inputPadding =
  EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD);
}