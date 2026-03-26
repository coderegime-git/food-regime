// lib/constants/asset_constants.dart

/// Centralized asset paths — images, icons, animations, fonts.
class AssetConstants {
  AssetConstants._();

  // ─── Base Paths ────────────────────────────────────────────────────────────
  static const String _images = 'assets/images/';
  static const String _icons = 'assets/icons/';
  static const String _animations = 'assets/animations/';

  // ─── Images ────────────────────────────────────────────────────────────────
  static const String logoFull = '${_images}logo_full.png';
  static const String logoIcon = '${_images}logo_icon.png';
  static const String splashBg = '${_images}splash_bg.png';
  static const String onboarding1 = '${_images}onboarding_1.png';
  static const String onboarding2 = '${_images}onboarding_2.png';
  static const String onboarding3 = '${_images}onboarding_3.png';
  static const String loginScreen = '${_images}login.jpg';
  static const String password = '${_images}password.png';
  static const String otpSuccess = '${_images}otp_success.png';
  static const String emptyCart = '${_images}empty_cart.png';
  static const String emptyOrders = '${_images}empty_orders.png';
  static const String emptySearch = '${_images}empty_search.png';
  static const String errorIllustration = '${_images}error.png';
  static const String orderSuccess = '${_images}order_success.png';
  static const String mapPlaceholder = '${_images}map_placeholder.png';
  static const String defaultFood = '${_images}default_food.png';
  static const String defaultRestaurant = '${_images}default_restaurant.png';
  static const String defaultAvatar = '${_images}default_avatar.png';

  // ─── Icons (SVG) ───────────────────────────────────────────────────────────
  static const String iconHome = '${_icons}home.svg';
  static const String iconSearch = '${_icons}search.svg';
  static const String iconCart = '${_icons}cart.svg';
  static const String iconProfile = '${_icons}profile.svg';
  static const String iconOrders = '${_icons}orders.svg';
  static const String iconLocation = '${_icons}location.svg';
  static const String iconStar = '${_icons}star.svg';
  static const String iconClock = '${_icons}clock.svg';
  static const String iconMotorbike = '${_icons}motorbike.svg';
  static const String iconHeart = '${_icons}heart.svg';
  static const String iconHeartFilled = '${_icons}heart_filled.svg';
  static const String iconFilter = '${_icons}filter.svg';
  static const String iconNotification = '${_icons}notification.svg';
  static const String iconArrowBack = '${_icons}arrow_back.svg';
  static const String iconCoupon = '${_icons}coupon.svg';
  static const String iconWallet = '${_icons}wallet.svg';
  static const String iconCard = '${_icons}card.svg';
  static const String iconCash = '${_icons}cash.svg';
  static const String iconGoogle = '${_icons}google.svg';
  static const String iconApple = '${_icons}apple.svg';
  static const String iconFacebook = '${_icons}facebook.svg';

  // ─── Lottie Animations ─────────────────────────────────────────────────────
  static const String animSplash = '${_animations}splash.json';
  static const String animLoading = '${_animations}loading.json';
  static const String animOrderSuccess = '${_animations}order_success.json';
  static const String animDelivery = '${_animations}delivery.json';
  static const String animEmptyCart = '${_animations}empty_cart.json';
  static const String animError = '${_animations}error.json';
  static const String animConfetti = '${_animations}confetti.json';

  // ─── Fonts ─────────────────────────────────────────────────────────────────
  static const String fontPoppins = 'Poppins';
}
