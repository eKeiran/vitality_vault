import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vitality_vault/pages/dashboard_page.dart';
import 'package:vitality_vault/theme/app_theme.dart';
import 'package:vitality_vault/widgets/app_navbar.dart';
import 'package:vitality_vault/pages/landing_page.dart';
import 'package:vitality_vault/pages/sign_in_page.dart';
import 'package:vitality_vault/pages/sign_up_page.dart';
import 'package:vitality_vault/pages/upload_page.dart';
import 'package:vitality_vault/pages/home_page.dart';
import 'package:vitality_vault/pages/onboarding_page.dart';
import 'package:vitality_vault/firebase_options.dart';
import 'package:vitality_vault/providers/theme_provider.dart';
import 'package:vitality_vault/providers/user_provider.dart';
import 'auth_wrapper.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const VitalityVaultApp(),
    ),
  );
}

class VitalityVaultApp extends StatelessWidget {
  const VitalityVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Vitality Vault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(), // Main entry point handles auth flow
      routes: {
        // Keep all your existing routes for direct navigation
        '/signin': (context) => const Scaffold(
              body: SignInPage(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppNavbar(),
              ),
            ),
        '/signup': (context) => const Scaffold(
              body: SignUpPage(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppNavbar(),
              ),
            ),
        '/onboarding': (context) => const Scaffold(
              body: OnboardingPage(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppNavbar(),
              ),
            ),
        '/home': (context) => const Scaffold(
              body: HomePage(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppNavbar(),
              ),
            ),
        '/uploads': (context) => const Scaffold(
              body: UploadSection(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppNavbar(),
              ),
            ),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AnalysisDashboard(
            userId: args['userId'],
            sessionId: args['sessionId'],
          );
        },
      },
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
    );
  }
}
