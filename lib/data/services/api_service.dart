import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  // Helper method to handle responses
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      return {
        'code': 500,
        'message': 'Failed to parse response',
        'error': e.toString(),
      };
    }
  }

  // Add this method to get all users
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getUsers),
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (response.statusCode == 200 && data['code'] == 200) {
        final List usersData = data['users'] ?? [];
        return usersData.map((item) => User.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
  // ============ AUTH ============
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (response.statusCode == 200 && data['code'] == 200) {
        final userData = data['user'] ?? {};
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': User.fromJson(userData),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.signup),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': response.statusCode == 200 && data['code'] == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ============ CATEGORIES ============
  static Future<List<Category>> getCategories(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.getCategories}?user_id=$userId'),
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (response.statusCode == 200 && data['code'] == 200) {
        final List categoriesData = data['categories'] ?? [];
        return categoriesData.map((item) => Category.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addCategory(
      String userId,
      String name,
      String type,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.addCategory),
        body: {
          'user_id': userId,
          'name': name,
          'type': type,
        },
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': response.statusCode == 200 && data['code'] == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.deleteCategory}?id=$categoryId'),
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': response.statusCode == 200 && data['code'] == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ============ TRANSACTIONS ============
  static Future<List<Transaction>> getTransactions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.getTransactions}?user_id=$userId'),
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (response.statusCode == 200 && data['code'] == 200) {
        final List transactionsData = data['transactions'] ?? [];
        return transactionsData.map((item) => Transaction.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addTransaction({
    required String userId,
    required String categoryId,
    required String amount,
    required String date,
    String note = '',
    required String categoryName,
    required String categoryType, // Add this parameter
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.addTransaction),
        body: {
          'user_id': userId,
          'category_id': categoryId,
          'category_name': categoryName, // Send category name
          'category_type': categoryType, // Send category type
          'amount': amount,
          'date': date,
          'note': note,
        },
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': response.statusCode == 200 && data['code'] == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteTransaction(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.deleteTransaction),
        body: {'transaction_id': transactionId},
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': response.statusCode == 200 && data['code'] == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ============ REPORTS ============
  static Future<Map<String, dynamic>> getOverview(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getOverview),
        body: {'user_id': userId},
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        return {
          'success': true,
          'overview': data['overview'] ?? [],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch overview',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getReports(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getReports),
        body: {'user_id': userId},
      ).timeout(timeout);

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        return {
          'success': true,
          'income': double.tryParse(data['income']?.toString() ?? '0') ?? 0,
          'expense': double.tryParse(data['expense']?.toString() ?? '0') ?? 0,
          'balance': double.tryParse(data['balance']?.toString() ?? '0') ?? 0,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch reports',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ============ USER ============
  // static Future<List<User>> getUsers() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(ApiEndpoints.getUsers),
  //     ).timeout(timeout);
  //
  //     final data = _parseResponse(response);
  //
  //     if (response.statusCode == 200 && data['code'] == 200) {
  //       final List usersData = data['users'] ?? [];
  //       return usersData.map((item) => User.fromJson(item)).toList();
  //     }
  //
  //     return [];
  //   } catch (e) {
  //     return [];
  //   }
  // }

  static Future<Map<String, dynamic>> updateUser({
    required String id,
    required String name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.updateUser),
        body: {
          'action': 'update_user',
          'id': id,
          'name': name,
          'email': email,
        },
      ).timeout(timeout);

      final data = _parseResponse(response);
      return {
        'success': data['status'] == 'success',
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}