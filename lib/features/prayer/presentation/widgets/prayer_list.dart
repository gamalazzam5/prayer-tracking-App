import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_entity.dart';
import '../cubit/next_prayer_cubit.dart';
import '../cubit/next_prayer_state.dart';
import '../cubit/prayer_cubit.dart';
import 'prayer_tile.dart';

/// The five prayer rows for the selected day.
class PrayerList extends StatelessWidget {
  final List<PrayerEntity> prayers;
  final DateTime date;

  /// Injected so the "is this prayer in the past?" check is testable.
  final DateTime Function() now;

  const PrayerList({
    super.key,
    required this.prayers,
    required this.date,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final currentTime = now();
    final isToday = DateFormatter.isSameDay(date, currentTime);

    // The highlight only applies to today, so read the index once here rather
    // than rebuilding every tile on each countdown tick.
    final highlightedIndex = isToday
        ? context.select<NextPrayerCubit, int?>((cubit) {
            final state = cubit.state;
            return state is NextPrayerReady && !state.nextPrayer.isTomorrow
                ? state.nextPrayer.index
                : null;
          })
        : null;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.r),
            topLeft: Radius.circular(10.r),
          ),
        ),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          itemCount: prayers.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            return PrayerTile(
              prayer: prayer,
              isNext: index == highlightedIndex,
              // A past day is always recordable; today only up to now.
              canRecord: !isToday || !prayer.time.isAfter(currentTime),
              onStatusSelected: (status) => context
                  .read<PrayerCubit>()
                  .recordStatus(prayer: prayer, status: status),
            );
          },
        ),
      ),
    );
  }
}
