import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/localization/app_language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_provider.dart';
import 'firebase_options.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (wrapped in try-catch for offline/web test environments)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init note: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentThemeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: appLanguageNotifier,
          builder: (context, currentLocale, child) {
            return MaterialApp.router(
              title: 'Zana App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,
              locale: currentLocale,
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}