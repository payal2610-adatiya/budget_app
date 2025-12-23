import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/expense_card.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    List<dynamic> transactions;
    switch (_selectedFilter) {
      case 'expense':
        transactions = transactionProvider.getExpenses();
        break;
      case 'income':
        transactions = transactionProvider.getIncome();
        break;
      default:
        transactions = transactionProvider.transactions;
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('All Transactions', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Expense'),
                const SizedBox(width: 8),
                _buildFilterChip('Income'),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (authProvider.user != null) {
                  await transactionProvider.fetchTransactions(authProvider.user!.id);
                }
              },
              child: _buildTransactionsList(transactions, categoryProvider, transactionProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label.toLowerCase();
        });
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: AppStyles.bodyMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildTransactionsList(
      List<dynamic> transactions,
      CategoryProvider categoryProvider,
      TransactionProvider transactionProvider,
      ) {
    if (transactionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category = categoryProvider.getCategoryById(transaction.categoryId);

        return ExpenseCard(
          categoryName: transaction.categoryName,
          amount: '₹${transaction.amount.toStringAsFixed(2)}',
          date: transaction.date,
          note: transaction.note,
          categoryColor: category?.color ?? AppColors.primary,
          categoryIcon: category?.icon ?? Icons.category,
          isIncome: transaction.isIncome,
          onDelete: () {
            _deleteTransaction(transaction.id, transactionProvider);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            color: AppColors.textLight,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: AppStyles.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense or income',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(String transactionId, TransactionProvider transactionProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await transactionProvider.deleteTransaction(transactionId);
    }
  }
}