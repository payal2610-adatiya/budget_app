import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/local_storage.dart';

class AccountChecker {
  static Timer? _timer;
  static bool _isChecking = false;
  static Function()? _onUserDeleted;

  // Set callback for when user is deleted
  static void setOnUserDeletedCallback(Function() callback) {
    _onUserDeleted = callback;
  }

  // Start periodic checking (every 60 seconds)
  static void startPeriodicCheck() {
    const duration = Duration(seconds: 60);
    _timer?.cancel();
    _timer = Timer.periodic(duration, (timer) {
      _checkAccountStatus();
    });
  }

  // Stop checking (call on logout)
  static void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  // Check account status
  static Future<void> _checkAccountStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final user = LocalStorage.getUser();
      if (user == null) {
        _isChecking = false;
        return;
      }

      // Check if user is logged in via SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) {
        _isChecking = false;
        return;
      }

      // Get all users from server
      final users = await ApiService.getUsers();

      // Check if current user still exists in the list
      final userExists = users.any((u) => u.id == user.id);

      if (!userExists) {
        print('User ${user.id} not found in user list. Account deleted.');

        // User was deleted by admin - force logout
        await LocalStorage.clearUser();
        await prefs.setBool('isLoggedIn', false);

        // Notify UI
        if (_onUserDeleted != null) {
          _onUserDeleted!();
        }
      }

      await _saveLastCheckTime();
    } catch (e) {
      print('Error checking account status: $e');
      // Don't logout on network errors
    } finally {
      _isChecking = false;
    }
  }

  // Check on app startup
  static Future<bool> checkOnStartup() async {
    final user = LocalStorage.getUser();
    if (user == null) {
      print('No user in local storage');
      return false;
    }

    // Check if user is logged in via SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      print('User not logged in according to SharedPreferences');
      return false;
    }

    try {
      final users = await ApiService.getUsers();
      print('Found ${users.length} users on server');

      final userExists = users.any((u) => u.id == user.id);
      print('User ${user.id} exists on server: $userExists');

      if (!userExists) {
        print('User not found on server. Logging out...');
        await LocalStorage.clearUser();
        await prefs.setBool('isLoggedIn', false);
        return false;
      }
      return true;
    } catch (e) {
      print('Startup check failed: $e');
      // If API fails, assume user is valid (don't logout on network error)
      return true;
    }
  }

  static Future<void> _saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_account_check', DateTime.now().toIso8601String());
  }
}