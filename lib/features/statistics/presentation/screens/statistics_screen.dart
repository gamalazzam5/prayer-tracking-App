import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/prayer_statistics_entity.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../widgets/achievement_card.dart';
import '../widgets/status_summary_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) => switch (state) {
          StatisticsInitial() || StatisticsLoading() => const AppLoader(),
          StatisticsError(:final message) => AppErrorView(
              message: message,
              onRetry: context.read<StatisticsCubit>().loadStatistics,
            ),
          StatisticsLoaded(:final statistics) =>
            _StatisticsContent(statistics: statistics),
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final PrayerStatisticsEntity statistics;

  const _StatisticsContent({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final breakdowns = statistics.breakdowns;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Text('الاحصائيات', style: AppTextStyles.screenTitle)),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SectionTitle('إحصائيات الصلوات'),
              SizedBox(width: 8.w),
              Image.asset(AppAssets.analysisIcon, width: 24.w, height: 24.h),
            ],
          ),
          SizedBox(height: 12.h),
          AchievementCard(achievement: statistics.weekly),
          SizedBox(height: 16.h),
          SectionTitle('مُلخّص التقدم', style: AppTextStyles.screenTitle),
          SizedBox(height: 16.h),
          // A grid keeps the four cards aligned regardless of how many
          // statuses exist, instead of the hand-paired columns used before.
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.center,
            children: [
              for (final breakdown in breakdowns)
                StatusSummaryCard(breakdown: breakdown),
            ],
          ),
        ],
      ),
    );
  }
}
