import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/expense_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../screens/transactions/add_transaction_screen.dart';
import '../../screens/transactions/transactions_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    if (authProvider.user != null) {
      try {
        await transactionProvider.fetchTransactions(authProvider.user!.id);
        await categoryProvider.fetchCategories(authProvider.user!.id);
      } catch (e) {
        print('Error loading data: $e');
      }
    }

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to logout?',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final recentTransactions = transactionProvider.getRecentTransactions();
    final totalIncome = transactionProvider.getTotalIncome();
    final totalExpenses = transactionProvider.getTotalExpenses();
    final balance = transactionProvider.getBalance();

    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary,),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: AppStyles.bodySmall,


            ),
            Text(
                authProvider.user?.name.split(' ').first ?? 'User',
                style: AppStyles.headline3.copyWith(color: Colors.white)
            ),
          ],
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout_outlined),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppStyles.primaryCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${balance.toStringAsFixed(2)}',
                      style: AppStyles.numberLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIncomeExpenseCard(
                          title: 'Income',
                          amount: totalIncome,
                          color: AppColors.successLight,
                        ),
                        _buildIncomeExpenseCard(
                          title: 'Expenses',
                          amount: totalExpenses,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.arrow_upward,
                      label: 'Add Expense',
                      color: AppColors.error,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionScreen(type: 'expense'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.arrow_downward,
                      label: 'Add Income',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionScreen(type: 'income'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppStyles.headline3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Recent Transactions List
              if (transactionProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary,))
              else if (recentTransactions.isEmpty)
                _buildEmptyState()
              else
                ...recentTransactions.map((transaction) {
                  // Use safe methods to get category data
                  final categoryName = categoryProvider.getCategoryNameOrDefault(
                    transaction.categoryId,
                    transaction.categoryName.isNotEmpty
                        ? transaction.categoryName
                        : 'Unknown',
                  );

                  final categoryColor = categoryProvider.getCategoryColorOrDefault(
                    transaction.categoryId,
                    AppColors.primary,
                  );

                  final categoryIcon = categoryProvider.getCategoryIconOrDefault(
                    transaction.categoryId,
                    Icons.category,
                  );

                  return ExpenseCard(
                    categoryName: categoryName,
                    amount: '₹${transaction.amount.toStringAsFixed(2)}',
                    date: transaction.date,
                    note: transaction.note,
                    categoryColor: categoryColor,
                    categoryIcon: categoryIcon,
                    isIncome: transaction.isIncome,
                    onDelete: () {
                      _deleteTransaction(transaction.id, transactionProvider);
                    },
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppStyles.numberMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
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

  Future<void> _deleteTransaction(String transactionId, TransactionProvider transactionProvider) async {
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