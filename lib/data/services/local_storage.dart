import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Data
  static Future<void> saveUser(User user) async {
    if (_prefs == null) await init();
    await _prefs!.setString('user', json.encode(user.toJson()));
  }

  static User? getUser() {
    if (_prefs == null) return null;
    final userJson = _prefs!.getString('user');
    if (userJson == null) return null;
    try {
      final userMap = json.decode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    if (_prefs == null) await init();
    await _prefs!.remove('user');
  }

  // Categories
  static Future<void> saveCategories(List<Category> categories) async {
    if (_prefs == null) await init();
    final categoriesJson = categories.map((cat) => json.encode(cat.toJson())).toList();
    await _prefs!.setStringList('categories', categoriesJson);
  }

  static List<Category> getCategories() {
    if (_prefs == null) return [];
    final categoriesJson = _prefs!.getStringList('categories') ?? [];
    return categoriesJson.map((jsonStr) {
      try {
        return Category.fromJson(json.decode(jsonStr));
      } catch (e) {
        return null;
      }
    }).whereType<Category>().toList();
  }

  // Transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    if (_prefs == null) await init();
    final transactionsJson = transactions.map((t) => json.encode(t.toJson())).toList();
    await _prefs!.setStringList('transactions', transactionsJson);
  }

  static List<Transaction> getTransactions() {
    if (_prefs == null) return [];
    final transactionsJson = _prefs!.getStringList('transactions') ?? [];
    return transactionsJson.map((jsonStr) {
      try {
        return Transaction.fromJson(json.decode(jsonStr));
      } catch (e) {
        return null;
      }
    }).whereType<Transaction>().toList();
  }

  // Pending Operations
  static Future<void> addPendingTransaction(Transaction transaction) async {
    if (_prefs == null) await init();
    final pending = getPendingTransactions();
    pending.add(transaction);
    await savePendingTransactions(pending);
  }

  static Future<void> savePendingTransactions(List<Transaction> transactions) async {
    if (_prefs == null) await init();
    final transactionsJson = transactions.map((t) => json.encode(t.toJson())).toList();
    await _prefs!.setStringList('pending_transactions', transactionsJson);
  }

  static List<Transaction> getPendingTransactions() {
    if (_prefs == null) return [];
    final transactionsJson = _prefs!.getStringList('pending_transactions') ?? [];
    return transactionsJson.map((jsonStr) {
      try {
        return Transaction.fromJson(json.decode(jsonStr));
      } catch (e) {
        return null;
      }
    }).whereType<Transaction>().toList();
  }

  static Future<void> clearPendingTransactions() async {
    if (_prefs == null) await init();
    await _prefs!.remove('pending_transactions');
  }

  // App Settings
  static Future<void> setCurrency(String currency) async {
    if (_prefs == null) await init();
    await _prefs!.setString('currency', currency);
  }

  static String getCurrency() {
    if (_prefs == null) return 'INR';
    return _prefs!.getString('currency') ?? 'INR';
  }

  static Future<void> setThemeMode(String mode) async {
    if (_prefs == null) await init();
    await _prefs!.setString('theme_mode', mode);
  }

  static String getThemeMode() {
    if (_prefs == null) return 'light';
    return _prefs!.getString('theme_mode') ?? 'light';
  }

  static Future<void> setNotifications(bool enabled) async {
    if (_prefs == null) await init();
    await _prefs!.setBool('notifications', enabled);
  }

  static bool getNotifications() {
    if (_prefs == null) return true;
    return _prefs!.getBool('notifications') ?? true;
  }

  // Clear all data
  static Future<void> clearAll() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }
}