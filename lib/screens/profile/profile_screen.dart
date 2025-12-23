
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/services/pdf_services.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppStyles.headline2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User Name',
                          style: AppStyles.headline3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@email.com',
                          style: AppStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Member since ${DateFormat('MMM yyyy').format(user?.createdAt ?? DateTime.now())}',
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: _editProfile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export Data Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  _buildOptionItem(
                    icon: Icons.download_outlined,
                    title: 'Export Monthly Report',
                    onTap: _showExportDialog,
                  ),
                  const Divider(height: 24),
                  _buildOptionItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: _showHelpSupport,
                  ),
                  const Divider(height: 24),
                  _buildOptionItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: _showPrivacyPolicy,
                  ),
                  const Divider(height: 24),
                  _buildOptionItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: _showTermsConditions,
                  ),
                  const Divider(height: 24),
                  _buildOptionItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: _showAboutApp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: _logout,
              backgroundColor: AppColors.error,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Monthly Report',
                    style: AppStyles.headline3,
                  ),
                ],
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 500, // Limit maximum height
                maxWidth: 400,  // Limit maximum width for consistency
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Select month and year for report',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Month/Year Picker
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Selected Month Display
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('MMMM yyyy').format(_selectedDate),
                                    style: AppStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Year Selection with Arrows (2023-2030)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left, color: AppColors.primary),
                                  onPressed: _selectedDate.year > 2023
                                      ? () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate.year - 1,
                                        _selectedDate.month,
                                      );
                                    });
                                  }
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  constraints: const BoxConstraints(
                                    minWidth: 100,
                                    maxWidth: 150,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _selectedDate.year.toString(),
                                    style: AppStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right, color: AppColors.primary),
                                  onPressed: _selectedDate.year < 2030
                                      ? () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate.year + 1,
                                        _selectedDate.month,
                                      );
                                    });
                                  }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Year Quick Select (2023-2030) - Compact version
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: List.generate(8, (index) {
                              final year = 2023 + index;
                              final isSelected = year == _selectedDate.year;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = DateTime(year, _selectedDate.month);
                                  });
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 60,
                                    maxWidth: 70,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    year.toString(),
                                    style: AppStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),

                          // Month Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Changed from 3 to 4 for better fit
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 1.2, // Reduced aspect ratio
                            ),
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              final month = index + 1;
                              final isCurrentMonth = month == _selectedDate.month;
                              final monthName = DateFormat('MMM').format(DateTime(2023, month));

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = DateTime(_selectedDate.year, month);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCurrentMonth
                                        ? AppColors.primary
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isCurrentMonth
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      monthName,
                                      style: AppStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isCurrentMonth
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Report will include all transactions for selected month',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _generatePdfReport();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Generate',
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generatePdfReport() async {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    // Get the first day of selected month
    final targetMonth = DateTime(_selectedDate.year, _selectedDate.month);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Generating Report for ${DateFormat('MMMM yyyy').format(targetMonth)}...',
                style: AppStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Get user data
      final user = authProvider.user!;
      final transactions = transactionProvider.transactions;

      // Filter transactions by selected month
      final monthlyTransactions = transactions
          .where((t) =>
      t.date.year == targetMonth.year &&
          t.date.month == targetMonth.month)
          .toList();

      // Sort transactions by date (newest first)
      monthlyTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Get recent transactions (max 20 for better PDF layout)
      final recentTransactions = monthlyTransactions
          .take(20)
          .map((transaction) {
        final category =
        categoryProvider.getCategoryById(transaction.categoryId);
        return {
          'date': transaction.date,
          'category': category?.name ?? transaction.categoryName,
          'amount': transaction.amount,
          'isIncome': transaction.isIncome,
        };
      }).toList();

      // Calculate totals for selected month
      final totalIncome = monthlyTransactions
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalExpenses = monthlyTransactions
          .where((t) => !t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      final balance = totalIncome - totalExpenses;

      // Get category spending for selected month
      final List<Map<String, dynamic>> categorySpending = [];

      // Get expense transactions
      final expenseTransactions = monthlyTransactions
          .where((t) => !t.isIncome)
          .toList();

      // Group by category
      final Map<String, double> categoryTotals = {};

      for (final transaction in expenseTransactions) {
        final category =
        categoryProvider.getCategoryById(transaction.categoryId);
        final categoryName = category?.name ?? 'Uncategorized';
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
      }

      // Convert to list
      categoryTotals.forEach((categoryName, amount) {
        categorySpending.add({
          'name': categoryName,
          'amount': amount,
        });
      });

      // Sort by amount descending
      categorySpending.sort((a, b) => b['amount'].compareTo(a['amount']));

      // Generate PDF bytes
      final pdfBytes = await PdfService.generatePdf(
        userName: user.name,
        userEmail: user.email,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
        transactions: recentTransactions,
        categorySpending: categorySpending,
        selectedMonth: targetMonth,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Preview PDF
      await PdfService.previewPdf(pdfBytes);
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ... [Rest of the methods remain the same as in your code]
  // _editProfile, _showAboutApp, _showPrivacyPolicy, _showTermsConditions,
  // _showHelpSupport, _logout, etc.
  // Add the rest of your existing methods here...

  void _editProfile() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Profile',
                  style: AppStyles.headline3,
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppStyles.headline2.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                Text(
                  'Name',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    style: AppStyles.bodyLarge,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                      hintText: 'Enter your name',
                      hintStyle: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                Text(
                  'Email',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    style: AppStyles.bodyLarge,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      hintText: 'Enter your email',
                      hintStyle: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                // Basic validation
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Update profile
                await authProvider.updateProfile(
                  nameController.text,
                  emailController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Changes',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.info_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'About Budget Buddy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'v1.0.0\nYour Personal Finance Companion',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Budget Buddy helps you take control of your finances with easy expense tracking, budgeting tools, and financial insights.',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('📊 Track income and expenses'),
            _buildFeatureItem('🎯 Set and monitor budgets'),
            _buildFeatureItem('📈 View detailed reports'),
            _buildFeatureItem('🔔 Get spending alerts'),
            _buildFeatureItem('📱 Sync across devices'),
            const SizedBox(height: 16),
            Text(
              'Contact us: support@budgetbuddy.app',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.privacy_tip_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateFormat('dd MMM, yyyy').format(DateTime.now())}',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1. Information We Collect',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Account information (name, email)\n'
                        '• Financial data (transactions, budgets)\n'
                        '• Device information for app improvement',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2. How We Use Your Data',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• To provide and improve Budget Buddy services\n'
                        '• To generate financial reports\n'
                        '• To send important notifications\n'
                        '• For security and fraud prevention',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3. Data Security',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We use industry-standard encryption to protect your data. Your financial information is stored securely and never shared without your consent.',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terms of Use',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By using Budget Buddy, you agree to these Terms of Use.',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1. Account Terms',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You must provide accurate information when creating an account. You are responsible for keeping your login credentials secure.',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2. App Usage',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Budget Buddy is intended for personal financial management. You agree to use the app for lawful purposes only.',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3. Data Accuracy',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'While we strive for accuracy, Budget Buddy provides financial tools and insights, not professional financial advice.',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.help_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Help Center',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How can we help you today?',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Getting Started',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Add your first transaction from the dashboard\n'
                        '2. Create categories for your expenses\n'
                        '3. Set monthly budgets for each category\n'
                        '4. Check reports to see your spending patterns',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Contact Support',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email: help@budgetbuddyapp.com\n'
                        'Response time: 24-48 hours',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  void _logout() async {
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
      ),
    );

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }}