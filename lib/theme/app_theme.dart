// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/constants.dart';

/// Defines light and dark [ThemeData] for the FoodieGo app.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      //fontFamily: AssetConstants.fontPoppins,

      // ColorScheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.grey100,
        onSecondaryContainer: AppColors.secondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        outline: AppColors.lightBorder,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: UIConstants.spaceLG,
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: UIConstants.iconLG,
        ),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, UIConstants.buttonHeightLG),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceXXL,
            vertical: UIConstants.spaceMD,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: UIConstants.borderRadiusMD,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, UIConstants.buttonHeightLG),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceXXL,
            vertical: UIConstants.spaceMD,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: UIConstants.borderRadiusMD,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceLG,
            vertical: UIConstants.spaceSM,
          ),
          textStyle: AppTextStyles.buttonTextSmall,
          shape: RoundedRectangleBorder(
            borderRadius: UIConstants.borderRadiusSM,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: UIConstants.inputPadding,
        border: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextDisabled,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: UIConstants.cardElevation,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusLG,
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primarySurface,
        labelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusFull,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spaceMD,
          vertical: UIConstants.spaceXS,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: UIConstants.dividerThickness,
        space: 0,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusMD,
        ),
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusXXL,
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UIConstants.radiusXXL),
            topRight: Radius.circular(UIConstants.radiusXXL),
          ),
        ),
        elevation: 8,
        showDragHandle: true,
        dragHandleColor: AppColors.grey300,
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.lightBorder,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySurface,
        circularTrackColor: AppColors.primarySurface,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySurface;
          }
          return AppColors.grey200;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusXS,
        ),
        side: const BorderSide(color: AppColors.grey400, width: 1.5),
      ),

      // Text Styles
      textTheme: _buildTextTheme(isDark: false),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF3D1A0A),
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.darkSurfaceVariant,
        onSecondaryContainer: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        error: Color(0xFFEF9A9A),
        onError: AppColors.darkBackground,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusLG,
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: UIConstants.inputPadding,
        border: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextDisabled,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: UIConstants.dividerThickness,
        space: 0,
      ),
      textTheme: _buildTextTheme(isDark: true),
    );
  }

  // ─── Text Theme Builder ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: textColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: textColor),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: subColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: subColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: subColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: subColor),
    );
  }
}
