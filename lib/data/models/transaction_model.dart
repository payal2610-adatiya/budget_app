import 'dart:ui';

import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class Transaction {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      categoryType: json['category_type']?.toString() ?? 'expense',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      note: json['note']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_type': categoryType,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpense => categoryType == 'expense';
  bool get isIncome => categoryType == 'income';

  String get formattedAmount {
    return isExpense ? '-₹${amount.toStringAsFixed(2)}' : '+₹${amount.toStringAsFixed(2)}';
  }

  Color get amountColor {
    return isIncome ? AppColors.success : AppColors.error;
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get formattedDateTime {
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? categoryType,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryType: categoryType ?? this.categoryType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}