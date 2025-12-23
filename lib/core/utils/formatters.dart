import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date);
  }

  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}