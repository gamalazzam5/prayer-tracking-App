import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_status.dart';
import 'status_option_tile.dart';

/// Dialog asking how the user performed [prayer].
///
/// Stateless: the current selection comes from the prayer itself, and picking
/// an option pops with the chosen status. That keeps the recording decision
/// with the cubit rather than in dialog-local state.
class PrayerStatusPicker extends StatelessWidget {
  final PrayerEntity prayer;

  const PrayerStatusPicker({super.key, required this.prayer});

  /// Shows the picker and resolves to the chosen status, or null if dismissed.
  static Future<PrayerStatus?> show(
    BuildContext context, {
    required PrayerEntity prayer,
  }) {
    return showDialog<PrayerStatus>(
      context: context,
      builder: (_) => PrayerStatusPicker(prayer: prayer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      backgroundColor: AppColors.white,
      titlePadding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
      title: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Image.asset(AppAssets.closeIcon, width: 24.w, height: 24.h),
          ),
          Expanded(
            child: Text(
              'كيف صليت ${prayer.name.arabicName} ؟',
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final status in PrayerStatus.values) ...[
            StatusOptionTile(
              status: status,
              isSelected: prayer.status == status,
              onTap: () => Navigator.of(context).pop(status),
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
