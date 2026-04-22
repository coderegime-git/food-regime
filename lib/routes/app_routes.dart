// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/profile/wallet_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/restaurant_detail_screen.dart';
import '../screens/order/confirm_order_screen.dart';
import '../screens/order/order_detail_screen.dart';
import '../screens/screens.dart';

/// Named route constants to avoid magic strings.
class AppRoutes {
  AppRoutes._();

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login:/isGuest';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String otp = '/auth/otp';
  static const String resetPassword = '/auth/reset-password';

  // ─── Main Shell (Bottom Nav) ───────────────────────────────────────────────
  static const String shell = '/app';
  static const String home = '/app/home';
  static const String search = '/app/search';
  static const String cart = '/app/cart';
  static const String orders = '/app/orders';
  static const String profile = '/app/profile';

  // ─── Restaurant ────────────────────────────────────────────────────────────
  static const String restaurantDetail = '/restaurant/:restaurantId';
  static const String restaurantMenu = '/restaurant/:restaurantId/menu';

  // ─── Food ──────────────────────────────────────────────────────────────────
  static const String foodDetail = '/food/:foodId';
  static const String categoryFoods = '/category/:categoryId';

  // ─── Order ─────────────────────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order/confirmation/:orderId';
  static const String orderTracking = '/order/tracking/:orderId';
  static const String orderDetail = '/order/detail/:orderId';

  // ─── Profile Sub-pages ─────────────────────────────────────────────────────
  static const String editProfile = '/profile/edit/:fromHome';
  static const String savedAddresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String paymentMethods = '/profile/payment';
  static const String notifications = '/profile/notifications';
  static const String favorites = '/profile/favorites';
  static const String settings = '/profile/settings';
  static const String helpCenter = '/profile/help/:page';
  static const String aboutApp = '/profile/about';
  static const String wallet = '/profile/wallet';
  static const String confirmOrder = '/confirm-order';
  static const String searchScreen = '/search-screen';

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static String restaurantDetailPath(String id) => '/restaurant/$id';

  static String foodDetailPath(String id) => '/food/$id';

  static String categoryFoodsPath(String id) => '/category/$id';

  static String orderConfirmationPath(String id) => '/order/confirmation/$id';

  static String orderTrackingPath(String id) => '/order/tracking/$id';

  static String orderDetailPath(String id) => '/order/detail/$id';

  static String editProfilePath(String fromHome) => '/profile/edit/$fromHome';

  static String staticPagePath(String page) => '/profile/help/$page';

  static String loginPath(bool isGuest) => '/auth/login/$isGuest';
}

/// The app's [GoRouter] configuration.
class AppRouter {
  AppRouter._();

  /// Navigator key for imperative navigation access.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // ── Error page ──────────────────────────────────────────────────────────
    errorBuilder: (context, state) => ErrorScreen(error: state.error),

    // ── Redirect logic ──────────────────────────────────────────────────────
    redirect: (context, state) {
      // TODO: Inject AuthNotifier here to check auth state
      // final isLoggedIn = ref.read(authProvider).isLoggedIn;
      // final isOnboarded = ref.read(onboardingProvider).isComplete;
      // if (!isOnboarded) return AppRoutes.onboarding;
      // if (!isLoggedIn && !_isPublicRoute(state.matchedLocation)) {
      //   return AppRoutes.login;
      // }
      return null;
    },

    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: '/auth/login/:isGuest', // <-- :isGuest is the path parameter
        name: 'login',
        builder: (context, state) {
          final isGuestString = state.pathParameters['isGuest'] ?? 'false';
          final isGuest = isGuestString.toLowerCase() == 'true';

          return LoginScreen(isGuest: isGuest);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // ── Main Shell (Bottom Nav) ────────────────────────────────────────────
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            MainShell(key: mainShellKey, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          // GoRoute(
          //   path: AppRoutes.search,
          //   name: 'search',
          //   builder: (context, state) {
          //     final query = state.uri.queryParameters['q'] ?? '';
          //     return SearchScreen(initialQuery: query);
          //   },
          // ),
          // GoRoute(
          //   path: AppRoutes.cart,
          //   name: 'cart',
          //   builder: (context, state) => const CartScreen(),
          // ),

          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            builder: (context, state) => const OrderHistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Restaurant ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.restaurantDetail,
        name: 'restaurantDetail',
        builder: (context, state) {
          final id = state.pathParameters['restaurantId']!;
          return RestaurantDetailScreen(restaurantId: id);
        },
      ),

      // ── Food Detail ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.foodDetail,
        name: 'foodDetail',
        builder: (context, state) {
          final id = state.pathParameters['foodId']!;
          return FoodDetailScreen(foodId: id);
        },
      ),

      // ── Category ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.categoryFoods,
        name: 'categoryFoods',
        builder: (context, state) {
          final id = state.pathParameters['categoryId']!;
          return CategoryFoodsScreen(categoryId: id);
        },
      ),

      // ── Checkout ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // ── Order ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.orderConfirmation,
        name: 'orderConfirmation',
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderConfirmationScreen(orderId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'orderTracking',
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        name: 'orderDetail',
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: id);
          // return const OrderDetailScreen();
        },
      ),

      // ── Profile Sub-pages ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) {
          final fromHome = state.pathParameters['fromHome'] ?? "";
          print("fromHome");
          print(fromHome);
          return EditProfileScreen(
              fromHome: fromHome == "fromHome" ? true : false);
          // return const OrderDetailScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.savedAddresses,
        name: 'savedAddresses',
        builder: (context, state) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: 'addAddress',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'paymentMethods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: 'helpCenter',
        builder: (context, state) {
          final page = state.pathParameters['page'] ?? "";
          print("fromHome");
          print(page);
          return HelpCenterScreen(page: page);
          // return const OrderDetailScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.aboutApp,
        name: 'aboutApp',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        name: 'wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: AppRoutes.confirmOrder,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return ConfirmOrderPage(
            restaurant: data['restaurant'],
            cartData: data['cartData'],
            onIncrement: data['onIncrement'],
            onDecrement: data['onDecrement'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.searchScreen,
        builder: (context, state) {
          return const SearchScreen();
        },
      ),
    ],
  );

  /// Helper: whether a path is accessible without auth.
  static bool _isPublicRoute(String location) {
    const publicRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.otp,
      AppRoutes.resetPassword,
    ];
    return publicRoutes.contains(location);
  }
}
