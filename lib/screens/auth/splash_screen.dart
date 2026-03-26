// lib/screens/auth/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:go_router/go_router.dart';
import '../../constants/constants.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';
import '../../utils/sharedpreference_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    //if (mounted) context.go(AppRoutes.onboarding);
    String? userId = SharedPreferenceHelper.getUserId();
    if (userId != null && userId != "" && userId != "0") {
      final data = await ApiService().getProfile();
      SharedPreferenceHelper.setUserObject(data);
      if (mounted) context.go(AppRoutes.home);
    } else {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: UIConstants.borderRadiusXXL,
                  ),
                  child: Image.asset("assets/images/logo.png"),
                ),
                const SizedBox(height: UIConstants.spaceXXL),
                /*  Text(
                  AppConstants.appName,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: UIConstants.spaceSM),
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
