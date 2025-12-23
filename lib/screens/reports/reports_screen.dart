import 'package:budget_app/screens/home/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = 'monthly';
  String _selectedChartType = 'incomevsexpense';
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now(); // Current date as default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectMonthAndYear(BuildContext context) async {
    // Show year picker first
    final year = await _showYearPicker(context);
    if (year == null) return;

    // Then show month picker
    final month = await _showMonthPicker(context, year);
    if (month == null) return;

    // Set the selected date to the 1st of selected month/year
    setState(() {
      _selectedDate = DateTime(year, month);
    });
  }

  Future<int?> _showYearPicker(BuildContext context) async {
    // Generate years from 2023 to 2030
    final years = List.generate(8, (i) => 2023 + i);

    return showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Year', style: AppStyles.headline3),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: years.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (_, i) {
                  final y = years[i];
                  final selected = y == _selectedDate.year;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, y),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        y.toString(),
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showMonthPicker(BuildContext context, int year) async {
    final months = List.generate(12, (i) => i + 1);

    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          'Select Month ($year)',
          style: AppStyles.headline3,
        ),
        content: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: months.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (_, i) {
              final m = months[i];
              final isSelected = m == _selectedDate.month && year == _selectedDate.year;
              return GestureDetector(
                onTap: () => Navigator.pop(context, m),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.primary,
                    ),
                  ),
                  child: Text(
                    DateFormat('MMM').format(DateTime(year, m)),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Cancel',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary,),
        ),
      );
    }

    // Get monthly data for charts
    final monthlyIncomeData = _getMonthlyIncomeData(transactionProvider);
    final monthlyExpenseData = _getMonthlyExpenseData(transactionProvider);

    // For the current selected period, get totals
    final totalIncome = _getFilteredIncome(transactionProvider);
    final totalExpenses = _getFilteredExpenses(transactionProvider);
    final balance = totalIncome - totalExpenses;

    // Prepare data for income vs expense chart
    final incomeExpenseData = [
      ChartData('Income', totalIncome, AppColors.success),
      ChartData('Expense', totalExpenses, AppColors.error),
    ];

    // Prepare monthly comparison data
    final monthlyComparisonData = _getMonthlyComparisonData(monthlyIncomeData, monthlyExpenseData);

    // Prepare category data for the selected period
    List<ChartData> expenseCategoryData = [];
    List<ChartData> incomeCategoryData = [];
    final categories = categoryProvider.categories;

    for (var category in categories) {
      final transactions = transactionProvider.getTransactionsByCategory(category.id);

      // Filter transactions by selected period
      final filteredTransactions = transactions.where((transaction) {
        return _isTransactionInPeriod(transaction.date, _selectedFilter);
      }).toList();

      double total = 0.0;

      for (var transaction in filteredTransactions) {
        if ((category.type == 'expense' && transaction.isExpense) ||
            (category.type == 'income' && !transaction.isExpense)) {
          total += transaction.amount;
        }
      }

      if (total > 0) {
        final chartData = ChartData(category.name, total, category.color);

        if (category.type == 'expense') {
          expenseCategoryData.add(chartData);
        } else if (category.type == 'income') {
          incomeCategoryData.add(chartData);
        }
      }
    }

    // Sort data
    expenseCategoryData.sort((a, b) => b.amount.compareTo(a.amount));
    incomeCategoryData.sort((a, b) => b.amount.compareTo(a.amount));

    final categoryData = expenseCategoryData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Reports & Analytics',style: TextStyle(color: Colors.white),),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards with period label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSummaryCard('Income', totalIncome, AppColors.success, Icons.arrow_downward),
                    const SizedBox(width: 8),
                    _buildSummaryCard('Expense', totalExpenses, AppColors.error, Icons.arrow_upward),
                    const SizedBox(width: 8),
                    _buildSummaryCard('Balance', balance, AppColors.primary, Icons.account_balance_wallet),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getPeriodLabel(_selectedFilter),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Section
            _buildFilterSection(),
            const SizedBox(height: 24),

            // Month/Year Selection Section (Only for Monthly filter)
            if (_selectedFilter == 'monthly')
              _buildMonthYearSelectionSection(),
            if (_selectedFilter == 'monthly')
              const SizedBox(height: 24),

            // Chart Display
            _buildChartDisplay(
              categoryData,
              incomeCategoryData,
              incomeExpenseData,
              monthlyComparisonData,
            ),
            const SizedBox(height: 24),

            // Monthly Income & Expense Trend
            if (monthlyComparisonData.isNotEmpty && _selectedFilter == 'monthly')
              _buildMonthlyTrendSection(monthlyComparisonData),

            // Category Breakdown - Show expense breakdown
            if (categoryData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Category Breakdown (${_getPeriodLabel(_selectedFilter).toLowerCase()})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...categoryData.map((item) {
                    final percentage = totalExpenses > 0 ? (item.amount / totalExpenses * 100) : 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(item.name),
                              color: item.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 4,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% of expenses',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₹${item.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

            // If no data at all
            if (totalIncome == 0 && totalExpenses == 0)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'View by Period',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((period) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(period),
                selected: _selectedFilter == period.toLowerCase(),
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = period.toLowerCase();
                    // Reset to current date when changing filter
                    if (_selectedFilter != 'monthly') {
                      _selectedDate = DateTime.now();
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedFilter == period.toLowerCase()
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Month & Year',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectMonthAndYear(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate.month == DateTime.now().month &&
                            _selectedDate.year == DateTime.now().year
                            ? 'Current Month'
                            : 'Viewing Previous Month',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Quick navigation buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today, size: 16),
                label: const Text('Current Month'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    // Go to previous month
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous Month'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartDisplay(
      List<ChartData> expenseCategoryData,
      List<ChartData> incomeCategoryData,
      List<ChartData> incomeExpenseData,
      List<MonthlyComparisonData> monthlyComparisonData
      ) {
    // If no income or expenses at all
    if (incomeExpenseData[0].amount == 0 && incomeExpenseData[1].amount == 0) {
      return _buildNoDataCard();
    }

    // Show selected chart - Only Monthly Trend and Income vs Expense options now
    if (_selectedChartType == 'monthlytrend') {
      // Show monthly trend chart
      if (monthlyComparisonData.isNotEmpty) {
        return _buildMonthlyTrendChart(monthlyComparisonData);
      } else {
        return _buildIncomeExpenseChart(incomeExpenseData);
      }
    } else {
      // Default to income vs expense
      return _buildIncomeExpenseChart(incomeExpenseData);
    }
  }

  Widget _buildMonthlyTrendChart(List<MonthlyComparisonData> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 320,
      child: Column(
        children: [
          Text(
            'Monthly Income vs Expenses (Last 6 Months)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: 45,
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.currency(symbol: '₹', decimalDigits: 0),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              series: <CartesianSeries>[
                ColumnSeries<MonthlyComparisonData, String>(
                  dataSource: data,
                  xValueMapper: (MonthlyComparisonData data, _) => data.monthName,
                  yValueMapper: (MonthlyComparisonData data, _) => data.income,
                  name: 'Income',
                  color: AppColors.success,
                ),
                ColumnSeries<MonthlyComparisonData, String>(
                  dataSource: data,
                  xValueMapper: (MonthlyComparisonData data, _) => data.monthName,
                  yValueMapper: (MonthlyComparisonData data, _) => data.expenses,
                  name: 'Expenses',
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(List<ChartData> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 300,
      child: Column(
        children: [
          Text(
            'Income vs Expenses (${_getPeriodLabel(_selectedFilter)})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.currency(symbol: '₹', decimalDigits: 0),
              ),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData data, _) => data.name,
                  yValueMapper: (ChartData data, _) => data.amount,
                  pointColorMapper: (ChartData data, _) => data.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendSection(List<MonthlyComparisonData> monthlyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Overview (Last 6 Months)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Income and expenses by month',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...monthlyData.reversed.map((monthData) {
          final balance = monthData.income - monthData.expenses;
          final isPositive = balance >= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthData.monthName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${balance.abs().toStringAsFixed(2)} ${isPositive ? 'Profit' : 'Loss'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniCard(
                        'Income',
                        '₹${monthData.income.toStringAsFixed(2)}',
                        AppColors.success,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMiniCard(
                        'Expenses',
                        '₹${monthData.expenses.toStringAsFixed(2)}',
                        AppColors.error,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMiniCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[300],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No chart data for ${_getPeriodLabel(_selectedFilter).toLowerCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add transactions to see charts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[300],
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No transaction data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add income and expense transactions to see reports',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  // ========== HELPER METHODS ==========

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'Today';
      case 'weekly':
        return 'This Week';
      case 'monthly':
        return DateFormat('MMMM yyyy').format(_selectedDate); // Show selected month name
      case 'yearly':
        return 'This Year';
      default:
        return 'All Time';
    }
  }

  bool _isTransactionInPeriod(DateTime transactionDate, String period) {
    final now = DateTime.now();

    switch (period) {
      case 'daily':
        return transactionDate.year == now.year &&
            transactionDate.month == now.month &&
            transactionDate.day == now.day;

      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return transactionDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(weekEnd.add(const Duration(days: 1)));

      case 'monthly':
      // Filter by selected month and year
        return transactionDate.year == _selectedDate.year &&
            transactionDate.month == _selectedDate.month;

      case 'yearly':
        return transactionDate.year == now.year;

      default:
        return true;
    }
  }

  double _getFilteredIncome(TransactionProvider provider) {
    double total = 0.0;

    for (var transaction in provider.transactions) {
      if (_isTransactionInPeriod(transaction.date, _selectedFilter)) {
        if (transaction.isIncome) {
          total += transaction.amount;
        }
      }
    }

    return total;
  }

  double _getFilteredExpenses(TransactionProvider provider) {
    double total = 0.0;

    for (var transaction in provider.transactions) {
      if (_isTransactionInPeriod(transaction.date, _selectedFilter)) {
        if (transaction.isExpense) {
          total += transaction.amount;
        }
      }
    }

    return total;
  }

  // ========== NEW METHODS FOR MONTHLY DATA ==========

  Map<String, double> _getMonthlyIncomeData(TransactionProvider provider) {
    final Map<String, double> monthlyData = {};
    final incomeTransactions = provider.getIncome();

    for (var transaction in incomeTransactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);
      monthlyData.update(
        monthKey,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return monthlyData;
  }

  Map<String, double> _getMonthlyExpenseData(TransactionProvider provider) {
    final Map<String, double> monthlyData = {};
    final expenseTransactions = provider.getExpenses();

    for (var transaction in expenseTransactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);
      monthlyData.update(
        monthKey,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return monthlyData;
  }

  List<MonthlyComparisonData> _getMonthlyComparisonData(
      Map<String, double> incomeData,
      Map<String, double> expenseData,
      ) {
    final List<MonthlyComparisonData> result = [];

    // Get all unique months from both datasets
    final allMonths = {...incomeData.keys, ...expenseData.keys}.toList();

    // Sort months chronologically
    allMonths.sort((a, b) {
      final dateA = DateFormat('MMM yyyy').parse(a);
      final dateB = DateFormat('MMM yyyy').parse(b);
      return dateA.compareTo(dateB);
    });

    // Take last 6 months or all if less than 6
    final recentMonths = allMonths.length > 6 ? allMonths.sublist(allMonths.length - 6) : allMonths;

    for (var month in recentMonths) {
      result.add(MonthlyComparisonData(
        monthName: month,
        income: incomeData[month] ?? 0.0,
        expenses: expenseData[month] ?? 0.0,
      ));
    }

    return result;
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('food')) return Icons.restaurant;
    if (name.contains('transport')) return Icons.directions_car;
    if (name.contains('shop')) return Icons.shopping_bag;
    if (name.contains('bill') || name.contains('utility')) return Icons.receipt;
    if (name.contains('entertain')) return Icons.movie;
    if (name.contains('health')) return Icons.local_hospital;
    if (name.contains('educat')) return Icons.school;
    if (name.contains('house') || name.contains('rent')) return Icons.home;
    if (name.contains('income')) return Icons.arrow_upward;
    if (name.contains('salary')) return Icons.work;
    if (name.contains('investment')) return Icons.trending_up;
    return Icons.category;
  }
}

class ChartData {
  final String name;
  final double amount;
  final Color color;

  ChartData(this.name, this.amount, this.color);
}

class MonthlyComparisonData {
  final String monthName;
  final double income;
  final double expenses;

  MonthlyComparisonData({
    required this.monthName,
    required this.income,
    required this.expenses,
  });
}