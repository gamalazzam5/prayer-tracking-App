import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_status.dart';
import '../mappers/prayer_status_ui.dart';
import 'prayer_status_picker.dart';

/// A single prayer row: time, name, icon, and the status the user recorded.
class PrayerTile extends StatelessWidget {
  final PrayerEntity prayer;

  /// True when this is the upcoming prayer today — the tile is highlighted and
  /// shows "استعد للصلاه" instead of a status control.
  final bool isNext;

  /// False for a prayer whose time has not arrived yet, which cannot be
  /// recorded.
  final bool canRecord;

  final ValueChanged<PrayerStatus> onStatusSelected;

  const PrayerTile({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.canRecord,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        isNext ? AppColors.textPrimary : AppColors.textTertiary;

    return Container(
      height: 88.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: isNext ? AppColors.brownDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.r,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${DateFormatter.toTwelveHourLabel(prayer.time)}'
                  '${DateFormatter.meridiem(prayer.time)}',
                  style: AppTextStyles.tileTime.copyWith(color: foreground),
                ),
                SizedBox(height: 8.h),
                _StatusControl(
                  prayer: prayer,
                  isNext: isNext,
                  canRecord: canRecord,
                  onStatusSelected: onStatusSelected,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prayer.name.arabicName,
                      style: AppTextStyles.prayerNameAr.copyWith(
                        color: isNext
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      prayer.name.englishName,
                      style: AppTextStyles.prayerNameEn.copyWith(
                        color: isNext
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 6.w),
                Image.asset(
                  prayer.name.iconAsset,
                  width: 48.w,
                  height: 48.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The tappable pill on the left of a tile.
class _StatusControl extends StatelessWidget {
  final PrayerEntity prayer;
  final bool isNext;
  final bool canRecord;
  final ValueChanged<PrayerStatus> onStatusSelected;

  const _StatusControl({
    required this.prayer,
    required this.isNext,
    required this.canRecord,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isNext) {
      return _Pill(
        color: AppColors.greenDark,
        child: Text('استعد للصلاه', style: AppTextStyles.onAccent),
      );
    }

    final status = prayer.status;

    return GestureDetector(
      onTap: canRecord ? () => _pickStatus(context) : null,
      child: Opacity(
        opacity: canRecord ? 1 : 0.5,
        child: _Pill(
          color: AppColors.greenSurface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  status?.label ?? 'حدد الحاله',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.statusLabel.copyWith(
                    color: status?.color ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (status != null) ...[
                SizedBox(width: 5.w),
                SvgPicture.asset(
                  status.iconAsset,
                  width: 24.w,
                  height: 24.h,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStatus(BuildContext context) async {
    final selected = await PrayerStatusPicker.show(context, prayer: prayer);
    if (selected != null) onStatusSelected(selected);
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Pill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 95.w, maxWidth: 130.w),
      height: 36.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}
