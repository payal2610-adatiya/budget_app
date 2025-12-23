import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/category_chip.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  final List<String> _predefinedCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Healthcare',
    'Education',
    'Housing',
    'Salary',
    'Freelance',
    'Investment',
    'Gifts',
    'Travel',
    'Personal',
    'Other',
  ];
  String? _selectedPredefined;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _selectedPredefined ?? _nameController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a category name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    final success = await categoryProvider.addCategory(
      authProvider.user!.id,
      categoryName,
      _selectedType,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(categoryProvider.errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _selectPredefinedCategory(String category) {
    setState(() {
      _selectedPredefined = category;
      _nameController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Add Category',style: TextStyle(color: Colors.white),),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Type Selection
                Text(
                  'Category Type',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Expense'),
                        selected: _selectedType == 'expense',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = 'expense';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Income'),
                        selected: _selectedType == 'income',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = 'income';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Predefined Categories
                Text(
                  'Quick Select',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _predefinedCategories.map((category) {
                    final isSelected = _selectedPredefined == category;
                    return CategoryChip(
                      name: category,
                      color: _getCategoryColor(category),
                      icon: _getCategoryIcon(category),
                      isSelected: isSelected,
                      onTap: () => _selectPredefinedCategory(category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Custom Category Name
                Text(
                  'Or Enter Custom Name',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Category Name',
                  prefixIcon: const Icon(Icons.category_outlined),
                  validator: (value) {
                    if (_selectedPredefined == null && (value == null || value.isEmpty)) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                  onTap: () {
                    setState(() {
                      _selectedPredefined = null;
                    });
                  },
                ),
                const SizedBox(height: 40),
                // Add Button
                CustomButton(
                  text: 'Add Category',
                  onPressed: _addCategory,
                  isLoading: categoryProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return AppColors.foodColor;
      case 'transport':
        return AppColors.transportColor;
      case 'shopping':
        return AppColors.shoppingColor;
      case 'bills':
        return AppColors.billsColor;
      case 'entertainment':
        return AppColors.entertainmentColor;
      case 'healthcare':
        return AppColors.healthcareColor;
      case 'education':
        return AppColors.educationColor;
      case 'housing':
        return AppColors.housingColor;
      case 'salary':
      case 'freelance':
      case 'investment':
        return AppColors.incomeColor;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'housing':
        return Icons.home;
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.computer;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}