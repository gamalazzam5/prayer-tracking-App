import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../prayer/domain/entities/prayer_name.dart';
import '../../../prayer/presentation/mappers/prayer_status_ui.dart';
import '../../domain/entities/status_breakdown_entity.dart';
import 'status_bar.dart';

/// Per-status card: one bar per prayer, plus the overall share and count.
class StatusSummaryCard extends StatelessWidget {
  final StatusBreakdownEntity breakdown;

  const StatusSummaryCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final color = breakdown.status.chartColor;
    final percentage = (breakdown.shareOfAll * 100).round();

    return AppCard(
      width: 173.w,
      height: 112.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final name in PrayerName.values)
                StatusBar(
                  color: color,
                  share: breakdown.perPrayerShare[name] ?? 0,
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    breakdown.status.iconAsset,
                    width: 24.w,
                    height: 24.h,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    breakdown.status.label,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.statusLabel.copyWith(color: color),
                  ),
                  Text('$percentage%', style: AppTextStyles.prayerNameEn),
                  Text(
                    '${breakdown.count} مره',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.prayerNameEn,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
