import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              // App Name
              Text(
                'BudgetTrack',
                style: AppStyles.headline1.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              Text(
                'Track Expenses. Control Budget. Save More.',
                style: AppStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Get Started Button
              CustomButton(
                text: 'Get Started',
                onPressed: () async {
                  await _completeOnboarding();
                  Navigator.pushReplacementNamed(context, '/signup');
                },
              ),
              const SizedBox(height: 16),
              // Login Button
              CustomButton(
                text: 'Login',
                onPressed: () async {
                  await _completeOnboarding();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                isOutlined: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}