import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class Dialogs {
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppStyles.headline3),
        content: Text(message, style: AppStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: AppStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(confirmText, style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showErrorDialog({
    required BuildContext context,
    required String message,
    String title = 'Error',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppStyles.headline3),
        content: Text(message, style: AppStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String message,
    String title = 'Success',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppStyles.headline3),
        content: Text(message, style: AppStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary
                ,),
              const SizedBox(width: 20),
              Text(message, style: AppStyles.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}