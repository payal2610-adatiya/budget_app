import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();

    await Future.delayed(const Duration(seconds: 5));

    // Check authentication status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    // Navigate to appropriate screen
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'BudgetTrack',
              style: AppStyles.headline1.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Track Expenses. Control Budget. Save More.',
              style: AppStyles.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}