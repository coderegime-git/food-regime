// lib/constants/app_constants.dart

import '../model/home_data.dart';

/// Core application constants used throughout the app.
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'FoodRegime';
  static const String appTagline = 'Delicious food, delivered fast';
  static const String appVersion = ' 1.0.0';
  static const String oldVersion = ' 1.0.0';

  // ─── API Configuration ─────────────────────────────────────────────────────
  static const String baseUrl =
      'https://foodregime.coderegimetechnologies.com/';
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // ─── Storage Keys ──────────────────────────────────────────────────────────
  static const String kAuthToken = 'auth_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserId = 'user_id';
  static const String kOnboardingComplete = 'onboarding_complete';
  static const String kSelectedAddress = 'selected_address';
  static const String kCartItems = 'cart_items';
  static const String kThemeMode = 'theme_mode';

  // ─── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // ─── Delivery ──────────────────────────────────────────────────────────────
  static const double freeDeliveryThreshold = 30.0;
  static const double defaultDeliveryFee = 2.99;
  static const double taxRate = 0.08; // 8%
  static const int estimatedDeliveryMinMin = 20;
  static const int estimatedDeliveryMinMax = 45;

  // ─── Map & Location ────────────────────────────────────────────────────────
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;
  static const double defaultMapZoom = 14.0;
  static const double deliveryRadiusKm = 10.0;

  // ─── Animation Durations ───────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);

  // ─── Validation ────────────────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;

  // ─── Image Sizes ───────────────────────────────────────────────────────────
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 80.0;
  static const double restaurantCardImageHeight = 180.0;
  static const double foodCardImageHeight = 140.0;

  // ─── Cache ─────────────────────────────────────────────────────────────────
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxCacheSize = 200; // MB

  // ─── Rating ────────────────────────────────────────────────────────────────
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // ─── Order Status ──────────────────────────────────────────────────────────
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusOnTheWay = 'on_the_way';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  static List<Coupon>? coupons = [];
  static List<Category>? categories = [];
}
