import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class ExpenseCard extends StatelessWidget {
  final String categoryName;
  final String amount;
  final DateTime date;
  final String? note;
  final Color categoryColor;
  final IconData categoryIcon;
  final bool isIncome;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.date,
    this.note,
    required this.categoryColor,
    required this.categoryIcon,
    this.isIncome = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, yyyy').format(date),
                    style: AppStyles.bodySmall,
                  ),
                  if (note != null && note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        note!,
                        style: AppStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Amount and Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isIncome ? '+$amount' : '-$amount',
                  style: AppStyles.numberSmall.copyWith(
                    color: isIncome ? AppColors.success : AppColors.error,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}