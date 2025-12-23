import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; // 'expense' or 'income'
  final DateTime? selectedDate;

  const AddTransactionScreen({
    super.key,
    required this.type,
    this.selectedDate,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(); // Add separate controller for date

  String? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _categoriesLoaded = false;
  bool _loadingError = false;

  @override
  void initState() {
    super.initState();

    // Initialize selected date with passed date or current date
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _dateController.text = Formatters.formatDate(_selectedDate); // Initialize date controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _categoriesLoaded = false;
      _loadingError = false;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.user != null) {
        await categoryProvider.fetchCategories(authProvider.user!.id);
      } else {
        throw Exception('User not authenticated');
      }

      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
          _loadingError = true;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
          _dateController.text = Formatters.formatDate(pickedDate);
        });
      }
    } catch (e) {
      print('Error showing date picker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting date: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get the selected category
    final selectedCategory = categoryProvider.getCategoryById(_selectedCategoryId!);

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected category not found'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate that the selected category type matches the transaction type
    if (selectedCategory.type != widget.type) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a ${widget.type} category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await transactionProvider.addTransaction(
        userId: authProvider.user!.id,
        categoryId: _selectedCategoryId!,
        amount: _amountController.text.trim(),
        date: Formatters.formatDateForApi(_selectedDate),
        note: _noteController.text.trim(),
        categoryName: selectedCategory.name,
        categoryType: selectedCategory.type,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.type == 'expense' ? 'Expense' : 'Income'} added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transactionProvider.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = widget.type == 'expense'
        ? categoryProvider.getExpenseCategories()
        : categoryProvider.getIncomeCategories();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.type == 'expense' ? 'Add Expense' : 'Add Income',
          style: AppStyles.headline3.copyWith(color: Colors.white)
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Debug info (remove in production)
                if (widget.selectedDate != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Pre-selected date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                          style: AppStyles.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                // Amount Input
                CustomTextField(
                  controller: _amountController,
                  labelText: 'Amount',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.currency_rupee),
                  validator: Validators.validateAmount,
                ),
                const SizedBox(height: 24),

                // Category Section
                _buildCategorySection(categories, categoryProvider),
                const SizedBox(height: 24),

                // Date Picker - FIXED VERSION
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _dateController,
                      labelText: 'Date',
                      isReadOnly: true,
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Notes Input
                CustomTextField(
                  controller: _noteController,
                  labelText: 'Notes (Optional)',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
                const SizedBox(height: 40),

                // Save Button
                CustomButton(
                  text: widget.type == 'expense' ? 'Save Expense' : 'Save Income',
                  onPressed: _submitTransaction,
                  isLoading: _isLoading,
                  isDisabled: !_categoriesLoaded || categories.isEmpty,
                  backgroundColor: widget.type == 'expense' ? AppColors.error : AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(List categories, CategoryProvider categoryProvider) {
    if (!_categoriesLoaded) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
    }

    if (_loadingError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.error.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load categories',
              style: AppStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Retry',
              onPressed: _loadCategories,
              height: 40,
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.warning.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(Icons.category, color: AppColors.warning, size: 48),
            const SizedBox(height: 12),
            Text(
              'No ${widget.type} categories found',
              style: AppStyles.bodyLarge.copyWith(color: AppColors.warning),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add ${widget.type} categories first',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}