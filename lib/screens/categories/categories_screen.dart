import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/category_chip.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Categories',style: TextStyle(color: Colors.white),),
        centerTitle: false,
        elevation: 0,
        // Remove the add icon from app bar since we're adding FAB
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Expense', 'expense'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Income', 'income'),
                ],
              ),
            ),
          ),
          // Categories List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (authProvider.user != null) {
                  await categoryProvider.fetchCategories(authProvider.user!.id);
                }
              },
              child: _buildCategoriesList(categoryProvider),
            ),
          ),
        ],
      ),
      // ADD FLOATING ACTION BUTTON HERE
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: const Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
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

  Widget _buildCategoriesList(CategoryProvider categoryProvider) {
    if (categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
    }

    List<dynamic> categories;
    switch (_selectedType) {
      case 'expense':
        categories = categoryProvider.getExpenseCategories();
        break;
      case 'income':
        categories = categoryProvider.getIncomeCategories();
        break;
      default:
        categories = categoryProvider.categories;
    }

    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, categoryProvider);
      },
    );
  }

  Widget _buildCategoryCard(dynamic category, CategoryProvider categoryProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 24,
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
                const SizedBox(height: 4),
                Text(
                  category.type.toUpperCase(),
                  style: AppStyles.bodySmall.copyWith(
                    color: category.type == 'income'
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _deleteCategory(category.id, categoryProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            color: AppColors.textLight,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: AppStyles.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button below to add your first category',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryId, CategoryProvider categoryProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category? This will also delete all transactions in this category.'),
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
      await categoryProvider.deleteCategory(categoryId);
    }
  }
}