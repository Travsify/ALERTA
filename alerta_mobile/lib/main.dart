import 'package:alerta_mobile/core/services/navigation_service.dart';
import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alerta_mobile/core/services/notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: const ProviderScope(child: AlertaApp()),
      ),
    ),
  );

  // Initialize Firebase (wrapped in try-catch to avoid crash if config is missing)
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
}

class AlertaApp extends StatelessWidget {
  const AlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: NavigationService().navigatorKey,
        title: 'Alerta',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
    );
  }
}
