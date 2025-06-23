import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitality_vault/pages/landing_page.dart';
import 'package:vitality_vault/pages/sign_in_page.dart';
import 'package:vitality_vault/pages/onboarding_page.dart';
import 'package:vitality_vault/pages/home_page.dart';
import 'package:vitality_vault/providers/user_provider.dart';
import 'package:vitality_vault/widgets/app_navbar.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Initialize user provider when auth state changes
        if (authSnapshot.connectionState == ConnectionState.active) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.initialize();
          });
        }

        // Loading state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (authSnapshot.data == null) {
          return Scaffold(
            body: const LandingPage(),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AppNavbar(),
            ),
          );
        }

        // Logged in - check if onboarding is complete
        return FutureBuilder<bool>(
          future: _checkOnboardingComplete(userProvider),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final onboardingComplete = onboardingSnapshot.data ?? false;
            return onboardingComplete
                ? const HomePage()
                : const OnboardingPage();
          },
        );
      },
    );
  }

  Future<bool> _checkOnboardingComplete(UserProvider userProvider) async {
    await userProvider.initialize();
    return userProvider.userProfile?['preferences']?['completed_onboarding'] ??
        false;
  }
}
