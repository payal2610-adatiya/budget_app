import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/category_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _monthlyBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final budgetProvider = context.read<BudgetProvider>();
    _monthlyBudgetController.text = budgetProvider.monthlyBudget.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _monthlyBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Budget Management',
          style: AppStyles.headline3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Budget Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.primaryCardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Budget',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${budgetProvider.monthlyBudget.toStringAsFixed(2)}',
                          style: AppStyles.numberLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _editMonthlyBudget,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  LinearProgressIndicator(
                    value: budgetProvider.getTotalPercentage() / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ₹${budgetProvider.getTotalSpent().toStringAsFixed(2)}',
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'Remaining: ₹${budgetProvider.getRemainingBudget().toStringAsFixed(2)}',
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Category Budgets Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Budgets',
                  style: AppStyles.headline3,
                ),
                Text(
                  DateFormat('MMM yyyy').format(budgetProvider.selectedMonth),
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category Budgets List
            ...categoryProvider.getExpenseCategories().map((category) {
              final spent = budgetProvider.getCategorySpent(category.id);
              final budget = category.budgetLimit ?? 0;
              final percentage = budget > 0 ? (spent / budget) * 100 : 0;
              final isOverBudget = spent > budget;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: AppStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${spent.toStringAsFixed(2)} / ₹${budget.toStringAsFixed(2)}',
                                style: AppStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editCategoryBudget(category),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    LinearProgressIndicator(
                      value: percentage > 100 ? 1.0 : percentage / 100,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? AppColors.error : AppColors.primary,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppStyles.bodySmall.copyWith(
                            color: isOverBudget ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                        if (isOverBudget)
                          Text(
                            'Over Budget!',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            // Set All Budgets Button
            CustomButton(
              text: 'Set All Category Budgets',
              onPressed: () {
                // TODO: Implement set all budgets
              },
              backgroundColor: AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _editMonthlyBudget() {
    showDialog(
      context: context,
      builder: (context) {
        final budgetProvider = context.read<BudgetProvider>();
        return AlertDialog(
          title: const Text('Set Monthly Budget'),
          content: TextFormField(
            controller: _monthlyBudgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Budget (₹)',
              prefixText: '₹ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final budget = double.tryParse(_monthlyBudgetController.text) ?? 0;
                budgetProvider.setMonthlyBudget(budget);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editCategoryBudget(Category category) {
    final budgetProvider = context.read<BudgetProvider>();
    final controller = TextEditingController(
      text: (category.budgetLimit ?? 0).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${category.name}'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final budget = double.tryParse(controller.text) ?? 0;
              budgetProvider.setCategoryBudget(category.id, budget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}