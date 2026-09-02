import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/weekly_achievement_entity.dart';

/// "أسبوع مبارك!" banner with the user's weekly completion.
class AchievementCard extends StatelessWidget {
  final WeeklyAchievementEntity achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final percentage = (achievement.progress * 100).round();

    return AppCard(
      width: 362.w,
      height: 108.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            AppAssets.achievementCard,
            width: 85.w,
            height: 72.h,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أسبوع مبارك!', style: AppTextStyles.sectionTitle),
                  SizedBox(height: 8.h),
                  Text(
                    'تقدمك هذا الأسبوع: $percentage٪',
                    style: AppTextStyles.bodyBold,
                  ),
                  Text(
                    achievement.isComplete
                        ? 'مبروك! أديت كل الصلوات!'
                        : 'واصل السعي لتحقيق الأفضل!',
                    style: AppTextStyles.bodyBold,
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
