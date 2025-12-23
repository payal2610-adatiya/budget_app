import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'expense'
  final DateTime createdAt;
  double? budgetLimit;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.createdAt,
    this.budgetLimit,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      budgetLimit: double.tryParse(json['budget_limit']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      if (budgetLimit != null) 'budget_limit': budgetLimit,
    };
  }

  Color get color {
    switch (name.toLowerCase()) {
      case 'food':
        return AppColors.foodColor;
      case 'transport':
      case 'travel':
        return AppColors.travelColor;
      case 'bills':
      case 'utilities':
        return AppColors.billsColor;
      case 'shopping':
        return AppColors.shoppingColor;
      case 'entertainment':
        return AppColors.entertainmentColor;
      case 'healthcare':
        return AppColors.healthcareColor;
      case 'salary':
      case 'income':
        return AppColors.incomeColor;
      case 'education':
        return AppColors.educationColor;
      case 'housing':
        return AppColors.housingColor;
      case 'savings':
        return AppColors.savingsColor;
      default:
        return AppColors.primary;
    }
  }

  IconData get icon {
    switch (name.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'travel':
        return Icons.flight;
      case 'bills':
        return Icons.receipt;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      case 'salary':
        return Icons.work;
      case 'income':
        return Icons.attach_money;
      case 'education':
        return Icons.school;
      case 'housing':
        return Icons.home;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    DateTime? createdAt,
    double? budgetLimit,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }
}