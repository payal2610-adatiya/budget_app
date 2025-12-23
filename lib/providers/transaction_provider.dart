import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage.dart';
import '../data/services/sync_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await LocalStorage.init();
    _transactions = LocalStorage.getTransactions();
    notifyListeners();
  }

  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transactions = await ApiService.getTransactions(userId);
      if (transactions.isNotEmpty) {
        _transactions = transactions;
        await LocalStorage.saveTransactions(transactions);
        _errorMessage = '';
      } else {
        // Load from local storage if API returns empty
        final localTransactions = LocalStorage.getTransactions();
        _transactions = localTransactions;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch transactions';
      // Load from local storage on error
      final localTransactions = LocalStorage.getTransactions();
      _transactions = localTransactions;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTransaction({
    required String userId,
    required String categoryId,
    required String amount,
    required String date,
    String note = '',
    required String categoryName,
    required String categoryType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.addTransaction(
        userId: userId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        categoryName: categoryName,
        categoryType: categoryType,
      );

      if (result['success'] == true) {
        final newTransaction = Transaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: userId,
          categoryId: categoryId,
          categoryName: categoryName,
          categoryType: categoryType,
          amount: double.parse(amount),
          date: DateTime.parse(date),
          note: note,
          createdAt: DateTime.now(),
        );

        _transactions.add(newTransaction);
        await LocalStorage.saveTransactions(_transactions);

        await fetchTransactions(userId);
        await SyncService.syncPendingOperations();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to add transaction';

        final newTransaction = Transaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: userId,
          categoryId: categoryId,
          categoryName: categoryName,
          categoryType: categoryType,
          amount: double.parse(amount),
          date: DateTime.parse(date),
          note: note,
          createdAt: DateTime.now(),
        );

        await LocalStorage.addPendingTransaction(newTransaction);
        _transactions.add(newTransaction);
        await LocalStorage.saveTransactions(_transactions);

        return true;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';

      final newTransaction = Transaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryType: categoryType,
        amount: double.parse(amount),
        date: DateTime.parse(date),
        note: note,
        createdAt: DateTime.now(),
      );

      await LocalStorage.addPendingTransaction(newTransaction);
      _transactions.add(newTransaction);
      await LocalStorage.saveTransactions(_transactions);

      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.deleteTransaction(transactionId);

      if (result['success'] == true) {
        _transactions.removeWhere((t) => t.id == transactionId);
        await LocalStorage.saveTransactions(_transactions);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete transaction';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== FILTERING METHODS FOR REPORTS ==========

  // Income filtering methods
  double getIncomeForDay(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day &&
          (t.categoryType.toLowerCase() == 'income' || !t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getIncomeForWeek(DateTime date) {
    try {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      return _transactions
          .where((t) =>
      t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          t.date.isBefore(weekEnd.add(const Duration(days: 1))) &&
          (t.categoryType.toLowerCase() == 'income' || !t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getIncomeForMonth(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month &&
          (t.categoryType.toLowerCase() == 'income' || !t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getIncomeForYear(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          (t.categoryType.toLowerCase() == 'income' || !t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  // Expense filtering methods
  double getExpensesForDay(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day &&
          (t.categoryType.toLowerCase() == 'expense' || t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getExpensesForWeek(DateTime date) {
    try {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      return _transactions
          .where((t) =>
      t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          t.date.isBefore(weekEnd.add(const Duration(days: 1))) &&
          (t.categoryType.toLowerCase() == 'expense' || t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getExpensesForMonth(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month &&
          (t.categoryType.toLowerCase() == 'expense' || t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getExpensesForYear(DateTime date) {
    try {
      return _transactions
          .where((t) =>
      t.date.year == date.year &&
          (t.categoryType.toLowerCase() == 'expense' || t.isExpense))
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  // Get transactions filtered by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    try {
      return _transactions.where((t) {
        return t.date.isAfter(start) && t.date.isBefore(end);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get transactions for specific day
  List<Transaction> getTransactionsForDay(DateTime date) {
    try {
      return _transactions.where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day).toList();
    } catch (e) {
      return [];
    }
  }

  // Get transactions for current week
  List<Transaction> getTransactionsForWeek(DateTime date) {
    try {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      return _transactions.where((t) =>
      t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          t.date.isBefore(weekEnd.add(const Duration(days: 1)))).toList();
    } catch (e) {
      return [];
    }
  }

  // Get transactions for specific month
  List<Transaction> getTransactionsForMonth(DateTime date) {
    try {
      return _transactions.where((t) =>
      t.date.year == date.year &&
          t.date.month == date.month).toList();
    } catch (e) {
      return [];
    }
  }

  // Get transactions for specific year
  List<Transaction> getTransactionsForYear(DateTime date) {
    try {
      return _transactions.where((t) =>
      t.date.year == date.year).toList();
    } catch (e) {
      return [];
    }
  }

  // ========== EXISTING METHODS ==========

  List<Transaction> getRecentTransactions({int count = 5}) {
    try {
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _transactions.take(count).toList();
    } catch (e) {
      return [];
    }
  }

  List<Transaction> getTransactionsByCategory(String categoryId) {
    try {
      return _transactions.where((t) => t.categoryId == categoryId).toList();
    } catch (e) {
      return [];
    }
  }

  List<Transaction> getTransactionsByType(String type) {
    try {
      return _transactions.where((t) => t.categoryType.toLowerCase() == type.toLowerCase()).toList();
    } catch (e) {
      return [];
    }
  }

  List<Transaction> getExpenses() {
    try {
      return _transactions.where((t) => t.isExpense).toList();
    } catch (e) {
      return [];
    }
  }

  List<Transaction> getIncome() {
    try {
      return _transactions.where((t) => t.isIncome).toList();
    } catch (e) {
      return [];
    }
  }

  double getTotalExpenses() {
    try {
      return getExpenses().fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getTotalIncome() {
    try {
      return getIncome().fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getBalance() {
    try {
      return getTotalIncome() - getTotalExpenses();
    } catch (e) {
      return 0.0;
    }
  }

  double getTotalForCategory(String categoryId) {
    try {
      final categoryTransactions = getTransactionsByCategory(categoryId);
      return categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  double getTotalForCategoryType(String type) {
    try {
      final typeTransactions = getTransactionsByType(type);
      return typeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  Map<String, double> getMonthlyExpenses() {
    try {
      final Map<String, double> monthlyExpenses = {};
      final expenses = getExpenses();

      for (var expense in expenses) {
        final monthKey = "${expense.date.year}-${expense.date.month}";
        monthlyExpenses.update(
          monthKey,
              (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }

      return monthlyExpenses;
    } catch (e) {
      return {};
    }
  }

  Map<String, double> getMonthlyIncome() {
    try {
      final Map<String, double> monthlyIncome = {};
      final income = getIncome();

      for (var inc in income) {
        final monthKey = "${inc.date.year}-${inc.date.month}";
        monthlyIncome.update(
          monthKey,
              (value) => value + inc.amount,
          ifAbsent: () => inc.amount,
        );
      }

      return monthlyIncome;
    } catch (e) {
      return {};
    }
  }

  List<Transaction> getTransactionsByMonth(int year, int month) {
    try {
      return _transactions.where((t) {
        return t.date.year == year && t.date.month == month;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void updateTransactionCategoryInfo(String transactionId, String categoryName, String categoryType) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        categoryName: categoryName,
        categoryType: categoryType,
      );
      notifyListeners();
      LocalStorage.saveTransactions(_transactions);
    }
  }
}