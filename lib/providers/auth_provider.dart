import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage.dart';
import '../data/services/sync_service.dart';
import 'account_status_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await LocalStorage.init();
    _isInitialized = true;
  }

  Future<bool> checkLoginStatus() async {
    if (!_isInitialized) {
      await _initialize();
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final storedUser = LocalStorage.getUser();
      if (storedUser != null) {
        _user = storedUser;
        // Sync data when user loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SyncService.syncData(_user!.id);
        });
        notifyListeners();
        return true;
      } else {
        // Clear invalid login state
        await prefs.setBool('isLoggedIn', false);
      }
    }

    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);

      if (result['success'] == true) {
        _user = result['user'];
        await LocalStorage.saveUser(_user!);

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Reset account status on new login
        final BuildContext? context = navigatorKey.currentContext;
        if (context != null) {
          final accountProvider = context.read<AccountStatusProvider>();
          accountProvider.reset();
          accountProvider.startPeriodicChecks();
        }

        await SyncService.syncData(_user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await ApiService.signup(name, email, password);

      _isLoading = false;

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Signup failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearUser();

    // Clear login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Stop periodic checks
    final BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      final accountProvider = context.read<AccountStatusProvider>();
      accountProvider.stopPeriodicChecks();
    }

    _user = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.updateUser(
        id: _user!.id,
        name: name,
        email: email,
      );

      if (result['success'] == true) {
        _user = _user!.copyWith(name: name, email: email);
        await LocalStorage.saveUser(_user!);
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}