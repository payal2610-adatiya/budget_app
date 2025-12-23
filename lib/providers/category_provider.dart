import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage.dart';
import '../core/constants/app_colors.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await LocalStorage.init();
    final categories = LocalStorage.getCategories();
    if (categories.isEmpty) {
      // Add default categories if none exist
      await _addDefaultCategories();
    } else {
      _categories = categories;
      notifyListeners();
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = getDefaultCategories();
    _categories = defaultCategories
        .map((data) => Category(
      id: DateTime.now().microsecondsSinceEpoch.toString() + data['name'],
      userId: 'default',
      name: data['name'],
      type: data['type'],
      createdAt: DateTime.now(),
    ))
        .toList();
    await LocalStorage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> fetchCategories(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await ApiService.getCategories(userId);
      if (categories.isNotEmpty) {
        _categories = categories;
        await LocalStorage.saveCategories(categories);
        _errorMessage = '';
      } else {
        // If no categories from API, load from local storage
        final localCategories = LocalStorage.getCategories();
        if (localCategories.isEmpty) {
          await _addDefaultCategories();
        } else {
          _categories = localCategories;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch categories';
      // Load from local storage on error
      final localCategories = LocalStorage.getCategories();
      if (localCategories.isEmpty) {
        await _addDefaultCategories();
      } else {
        _categories = localCategories;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(String userId, String name, String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.addCategory(userId, name, type);

      if (result['success'] == true) {
        // Create new category
        final newCategory = Category(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: userId,
          name: name,
          type: type,
          createdAt: DateTime.now(),
        );

        _categories.add(newCategory);
        await LocalStorage.saveCategories(_categories);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to add category';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      // Add locally for offline support
      final newCategory = Category(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );

      _categories.add(newCategory);
      await LocalStorage.saveCategories(_categories);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.deleteCategory(categoryId);

      if (result['success'] == true) {
        _categories.removeWhere((cat) => cat.id == categoryId);
        await LocalStorage.saveCategories(_categories);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete category';
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

  List<Category> getExpenseCategories() {
    return _categories.where((cat) => cat.type == 'expense').toList();
  }

  List<Category> getIncomeCategories() {
    return _categories.where((cat) => cat.type == 'income').toList();
  }

  Category? getCategoryById(String id) {
    try {
      if (_categories.isEmpty) return null;
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryNameOrDefault(String categoryId, String defaultValue) {
    final category = getCategoryById(categoryId);
    return category?.name ?? defaultValue;
  }

  Color getCategoryColorOrDefault(String categoryId, Color defaultColor) {
    final category = getCategoryById(categoryId);
    return category?.color ?? defaultColor;
  }

  IconData getCategoryIconOrDefault(String categoryId, IconData defaultIcon) {
    final category = getCategoryById(categoryId);
    return category?.icon ?? defaultIcon;
  }

  List<Map<String, dynamic>> getDefaultCategories() {
    return [
      {
        'name': 'Food',
        'type': 'expense',
        'color': AppColors.foodColor,
        'icon': Icons.restaurant,
      },
      {
        'name': 'Transport',
        'type': 'expense',
        'color': AppColors.transportColor,
        'icon': Icons.directions_car,
      },
      {
        'name': 'Shopping',
        'type': 'expense',
        'color': AppColors.shoppingColor,
        'icon': Icons.shopping_bag,
      },
      {
        'name': 'Bills',
        'type': 'expense',
        'color': AppColors.billsColor,
        'icon': Icons.receipt,
      },
      {
        'name': 'Entertainment',
        'type': 'expense',
        'color': AppColors.entertainmentColor,
        'icon': Icons.movie,
      },
      {
        'name': 'Healthcare',
        'type': 'expense',
        'color': AppColors.healthcareColor,
        'icon': Icons.local_hospital,
      },
      {
        'name': 'Salary',
        'type': 'income',
        'color': AppColors.incomeColor,
        'icon': Icons.work,
      },
      {
        'name': 'Freelance',
        'type': 'income',
        'color': AppColors.success,
        'icon': Icons.computer,
      },
      {
        'name': 'Investment',
        'type': 'income',
        'color': AppColors.savingsColor,
        'icon': Icons.trending_up,
      },
    ];
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}