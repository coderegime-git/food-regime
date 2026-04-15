// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/utils/notification_service.dart';
import 'package:food_delivery_app/utils/sharedpreference_helper.dart';

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper.init();
  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AppConfig.init();
  if (!kIsWeb) {
    await NotificationService.instance.init();
  }
  runApp(const FoodieGoApp());
}

class FoodieGoApp extends StatefulWidget {
  const FoodieGoApp({super.key});

  @override
  State<FoodieGoApp> createState() => _FoodieGoAppState();
}

class _FoodieGoAppState extends State<FoodieGoApp> {
  @override
  void initState() {
    ApiBaseHelper().initApiService(AppRouter.rootNavigatorKey);
    if (!kIsWeb) {
      updateFcm();
    }
    super.initState();
  }

  updateFcm() async {
    final data = FirebaseMessaging.instance;
    await data.requestPermission();
    final token = await data.getToken();
    if (token != null) {
      SharedPreferenceHelper.setFirebaseToken(token);
      final auhToken = SharedPreferenceHelper.getAuthToken();
      if (auhToken != null) {
        await ApiService().updateFCMToken(fcm: token);
      }
      print("FCM $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodRegime',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // builder: (context, child) {
      //   final width = MediaQuery.of(context).size.width;
      //
      //   double maxWidth = double.infinity;
      //
      //   if (width > 1200) {
      //     maxWidth = 1200;
      //   } else if (width > 800) {
      //     maxWidth = 900;
      //   }
      //
      //   return Center(
      //     child: SizedBox(
      //       width: maxWidth,
      //       child: child,
      //     ),
      //   );
      // },
      // Localization (extend as needed)
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
