import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../models/transaction_model.dart';

class SyncService {
  static Future<void> syncData(String userId) async {
    // Sync pending transactions
    final pendingTransactions = LocalStorage.getPendingTransactions();
    for (final transaction in pendingTransactions) {
      try {
        final result = await ApiService.addTransaction(
          userId: transaction.userId,
          categoryId: transaction.categoryId,
          amount: transaction.amount.toString(),
          date: transaction.date.toIso8601String().split('T')[0],
          note: transaction.note, categoryName: '', categoryType: '',
        );

        if (result['success'] == true) {
          // Remove from pending if successful
          final updatedPending = pendingTransactions.where((t) => t.id != transaction.id).toList();
          await LocalStorage.savePendingTransactions(updatedPending);
        }
      } catch (e) {
        // Keep in pending if sync fails
        print('Failed to sync transaction: $e');
      }
    }

    // Sync local categories and transactions with server
    try {
      final serverCategories = await ApiService.getCategories(userId);
      final serverTransactions = await ApiService.getTransactions(userId);

      // Save to local storage
      await LocalStorage.saveCategories(serverCategories);
      await LocalStorage.saveTransactions(serverTransactions);
    } catch (e) {
      print('Failed to sync from server: $e');
    }
  }

  static Future<void> syncPendingOperations() async {
    final user = LocalStorage.getUser();
    if (user != null) {
      await syncData(user.id);
    }
  }
}