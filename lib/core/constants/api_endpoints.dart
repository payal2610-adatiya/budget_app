class ApiEndpoints {
  static const String baseUrl = 'https://prakrutitech.xyz/payal';

  // Auth
  static const String login = '$baseUrl/login_user.php';
  static const String signup = '$baseUrl/add_user.php';

  // User
  static const String getUsers = '$baseUrl/view_user.php';
  static const String updateUser = '$baseUrl/update.php?action=update_user';
  static const String deleteUser = '$baseUrl/delete_user.php';

  // Categories
  static const String getCategories = '$baseUrl/view_category.php';
  static const String addCategory = '$baseUrl/add_category.php';
  static const String updateCategory = '$baseUrl/update.php?action=update_category';
  static const String deleteCategory = '$baseUrl/delete_category.php';

  // Transactions
  static const String getTransactions = '$baseUrl/view_transaction.php';
  static const String addTransaction = '$baseUrl/add_transactions.php';
  static const String updateTransaction = '$baseUrl/update.php?action=update_transaction';
  static const String deleteTransaction = '$baseUrl/delete_transaction.php';

  // Reports
  static const String getOverview = '$baseUrl/overview.php';
  static const String getReports = '$baseUrl/reports.php';

}