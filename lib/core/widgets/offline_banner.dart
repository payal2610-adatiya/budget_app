import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Some features may be limited.',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
              ),
              child: Text(
                'Retry',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}