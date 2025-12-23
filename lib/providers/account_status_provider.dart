import 'package:flutter/material.dart';
import '../data/account_checker/account_checker.dart';


class AccountStatusProvider extends ChangeNotifier {
  bool _isUserDeleted = false;
  bool _isChecking = false;

  bool get isUserDeleted => _isUserDeleted;
  bool get isChecking => _isChecking;

  // Check account status on app start
  Future<void> checkAccountStatusOnStart() async {
    _isChecking = true;
    notifyListeners();

    final isValid = await AccountChecker.checkOnStartup();
    _isUserDeleted = !isValid;

    _isChecking = false;
    notifyListeners();
  }

  // Start periodic checks
  void startPeriodicChecks() {
    AccountChecker.startPeriodicCheck();
  }

  // Stop periodic checks
  void stopPeriodicChecks() {
    AccountChecker.stopPeriodicCheck();
  }

  // Mark user as deleted (called from checker)
  void markUserAsDeleted() {
    _isUserDeleted = true;
    notifyListeners();
  }

  // Reset when user logs in again
  void reset() {
    _isUserDeleted = false;
    notifyListeners();
  }
}