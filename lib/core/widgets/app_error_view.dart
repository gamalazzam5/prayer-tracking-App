import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared empty/error state with an optional retry action.
class AppErrorView extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorView({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96.sp, color: AppColors.error),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.bodyBold,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
                child: Text(retryLabel, style: AppTextStyles.onAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
