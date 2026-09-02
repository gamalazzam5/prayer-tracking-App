import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../cubit/next_prayer_cubit.dart';
import '../cubit/next_prayer_state.dart';

/// Header card: the upcoming prayer, a live countdown and today's Hijri date.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NextPrayerCubit, NextPrayerState>(
      builder: (context, state) => switch (state) {
        NextPrayerUnavailable() => SizedBox(height: 0.18.sh),
        NextPrayerReady() => _NextPrayerCardBody(state: state),
      },
    );
  }
}

class _NextPrayerCardBody extends StatelessWidget {
  final NextPrayerReady state;

  const _NextPrayerCardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final prayer = state.nextPrayer.prayer;

    return Container(
      width: double.infinity,
      height: 0.18.sh,
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 23.w,
            child: Image.asset(
              AppAssets.whiteMosque,
              width: 168.w,
              height: 103.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              AppAssets.blackMosque,
              width: 158.w,
              height: 97.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 27.h,
            right: 16.w,
            child: SizedBox(
              width: 182.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _CountdownChip(remaining: state.nextPrayer.remaining),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'سيبدأ ${prayer.name.arabicName} بعد',
                          style: AppTextStyles.onCard,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 11.5.h),
                  Text(
                    state.hijriDate,
                    style: AppTextStyles.onCard,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.end,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormatter.toClockLabel(prayer.time),
                    style: AppTextStyles.bigClock,
                    textAlign: TextAlign.end,
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

class _CountdownChip extends StatelessWidget {
  final Duration remaining;

  const _CountdownChip({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: AppColors.brownDark,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Text(
          DateFormatter.toCountdown(remaining),
          style: AppTextStyles.clock,
        ),
      ),
    );
  }
}
