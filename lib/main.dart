// import 'package:budget_app/providers/auth_provider.dart';
// import 'package:budget_app/providers/budget_provider.dart';
// import 'package:budget_app/providers/category_provider.dart';
// import 'package:budget_app/providers/transaction_provider.dart';
// import 'package:budget_app/screens/auth/login_screen.dart';
// import 'package:budget_app/screens/auth/signup_screen.dart';
// import 'package:budget_app/screens/home/dashboard_screen.dart';
// import 'package:budget_app/screens/onboarding/onboarding_screen.dart';
// import 'package:budget_app/screens/splash/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'navigation/bottom_navigation.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize SharedPreferences
//   final prefs = await SharedPreferences.getInstance();
//   final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
//
//   runApp(MyApp(
//     isFirstLaunch: isFirstLaunch,
//   ));
// }
//
// class MyApp extends StatelessWidget {
//   final bool isFirstLaunch;
//
//   const MyApp({
//     super.key,
//     required this.isFirstLaunch,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => CategoryProvider()),
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//         ChangeNotifierProvider(create: (_) => BudgetProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Budget Tracker',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.teal,
//           fontFamily: 'Roboto',
//           scaffoldBackgroundColor: const Color(0xFFF8F9FA),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             iconTheme: IconThemeData(color: Colors.black),
//           ),
//         ),
//         home: const SplashScreen(),
//         routes: {
//           '/onboarding': (context) => const OnboardingScreen(),
//           '/login': (context) => const LoginScreen(),
//           '/signup': (context) => const SignupScreen(),
//           '/home': (context) => const BottomNavigation(),
//           '/dashboard': (context) => const DashboardScreen(),
//         },
//       ),
//     );
//   }
// }

import 'package:budget_app/providers/auth_provider.dart';
import 'package:budget_app/providers/budget_provider.dart';
import 'package:budget_app/providers/category_provider.dart';
import 'package:budget_app/providers/transaction_provider.dart';
import 'package:budget_app/providers/account_status_provider.dart';
import 'package:budget_app/screens/auth/login_screen.dart';
import 'package:budget_app/screens/auth/signup_screen.dart';
import 'package:budget_app/screens/home/dashboard_screen.dart';
import 'package:budget_app/screens/onboarding/onboarding_screen.dart';
import 'package:budget_app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(
    isFirstLaunch: isFirstLaunch,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({
    super.key,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => AccountStatusProvider()),
      ],
      child: MaterialApp(
        title: 'Budget Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: const AppLoader(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const BottomNavigation(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final prefs = snapshot.data!;
        final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

        if (isFirstLaunch) {
          return const OnboardingScreen();
        }

        return const AuthWrapper();
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = context.read<AuthProvider>();
    final accountProvider = context.read<AccountStatusProvider>();

    try {
      // First, check if user is logged in via SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // Try to load user from AuthProvider
        final isAuthenticated = await authProvider.checkLoginStatus();

        if (isAuthenticated) {
          // User is logged in, check if account still exists on server
          await accountProvider.checkAccountStatusOnStart();

          if (!accountProvider.isUserDeleted) {
            // User is valid, start periodic checks
            accountProvider.startPeriodicChecks();
          }
        } else {
          // User not in local storage but marked as logged in - clear state
          await prefs.setBool('isLoggedIn', false);
        }
      }
    } catch (e) {
      print('Error checking authentication: $e');
    }

    if (mounted) {
      setState(() {
        _checkingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accountProvider = Provider.of<AccountStatusProvider>(context);

    if (_checkingAuth) {
      return const SplashScreen();
    }

    // Check if account was deleted by admin
    if (accountProvider.isUserDeleted) {
      return _buildAccountDeletedScreen(context, accountProvider, authProvider);
    }

    // Check authentication status
    if (authProvider.isAuthenticated) {
      return const BottomNavigation();
    }

    return const LoginScreen();
  }

  Widget _buildAccountDeletedScreen(BuildContext context, AccountStatusProvider accountProvider, AuthProvider authProvider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Deleted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Your account has been deleted by the administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  // Logout and clear everything
                  authProvider.logout();
                  accountProvider.reset();
                  accountProvider.stopPeriodicChecks();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  'Go to Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}