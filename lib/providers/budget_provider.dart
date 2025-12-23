import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/local_storage.dart';

class BudgetProvider extends ChangeNotifier {
  List<Category> _categories = [];
  double _monthlyBudget = 0.0;
  DateTime _selectedMonth = DateTime.now();

  List<Category> get categories => _categories;
  double get monthlyBudget => _monthlyBudget;
  DateTime get selectedMonth => _selectedMonth;

  BudgetProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    await LocalStorage.init();
    _categories = LocalStorage.getCategories();
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  void setCategoryBudget(String categoryId, double budget) {
    try {
      final index = _categories.indexWhere((cat) => cat.id == categoryId);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(budgetLimit: budget);
        LocalStorage.saveCategories(_categories);
        notifyListeners();
      }
    } catch (e) {
      print('Error setting category budget: $e');
    }
  }

  double getCategorySpent(String categoryId) {
    try {
      final transactions = LocalStorage.getTransactions();
      final now = DateTime.now();

      final monthTransactions = transactions.where((t) {
        return t.categoryId == categoryId &&
            t.date.month == now.month &&
            t.date.year == now.year &&
            t.isExpense;
      }).toList();

      return monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getTotalSpent() {
    try {
      final transactions = LocalStorage.getTransactions();
      final now = DateTime.now();

      final monthTransactions = transactions.where((t) {
        return t.date.month == now.month && t.date.year == now.year && t.isExpense;
      }).toList();

      return monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getRemainingBudget() {
    try {
      return _monthlyBudget - getTotalSpent();
    } catch (e) {
      return _monthlyBudget;
    }
  }

  double getCategoryRemaining(String categoryId) {
    try {
      final category = _categories.firstWhere((cat) => cat.id == categoryId);
      final budget = category.budgetLimit ?? 0;
      final spent = getCategorySpent(categoryId);
      return budget - spent;
    } catch (e) {
      return 0.0;
    }
  }

  double getCategoryPercentage(String categoryId) {
    try {
      final category = _categories.firstWhere((cat) => cat.id == categoryId);
      final budget = category.budgetLimit ?? 0;
      if (budget <= 0) return 0;
      final spent = getCategorySpent(categoryId);
      return (spent / budget) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  double getTotalPercentage() {
    try {
      if (_monthlyBudget <= 0) return 0;
      final spent = getTotalSpent();
      return (spent / _monthlyBudget) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  List<Category> getOverBudgetCategories() {
    try {
      return _categories.where((category) {
        final budget = category.budgetLimit ?? 0;
        if (budget <= 0) return false;
        final spent = getCategorySpent(category.id);
        return spent > budget;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}