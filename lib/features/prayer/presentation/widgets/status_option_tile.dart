import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/prayer_status.dart';
import '../mappers/prayer_status_ui.dart';

/// One selectable row inside [PrayerStatusPicker].
class StatusOptionTile extends StatelessWidget {
  final PrayerStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusOptionTile({
    super.key,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenDark : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border, width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              status.pickerLabel,
              style: AppTextStyles.bodyBold.copyWith(
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SvgPicture.asset(
                status.iconAsset,
                width: 24.w,
                height: 24.h,
                colorFilter: isSelected
                    ? const ColorFilter.mode(AppColors.white, BlendMode.srcIn)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
