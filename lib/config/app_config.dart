// lib/config/app_config.dart

/// Environment and service initialization config.
class AppConfig {
  AppConfig._();

  static late final AppEnvironment environment;

  static Future<void> init({
    AppEnvironment env = AppEnvironment.development,
  }) async {
    environment = env;
    // TODO: Initialize services here:
    // await FirebaseApp.initializeApp();
    // await SharedPreferences.getInstance();
    // Sentry.init(...);
    // etc.
  }

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProduction => environment == AppEnvironment.production;
}

enum AppEnvironment { development, staging, production }
