import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../cubit/prayer_cubit.dart';
import '../cubit/prayer_state.dart';
import '../cubit/selected_date_cubit.dart';
import '../cubit/selected_date_state.dart';
import '../widgets/date_navigator.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list.dart';

/// Home tab: next-prayer card, day stepper and the day's prayer list.
class PrayerScreen extends StatelessWidget {
  /// Injected clock, so widget tests can pin the current time.
  final DateTime Function() now;

  const PrayerScreen({super.key, DateTime Function()? now})
      : now = now ?? DateTime.now;

  @override
  Widget build(BuildContext context) {
    // Reload the list whenever the selected day changes. A listener keeps that
    // wiring in one place instead of scattering it through the widgets.
    return BlocListener<SelectedDateCubit, SelectedDateState>(
      listener: (context, state) =>
          context.read<PrayerCubit>().loadPrayers(state.date),
      child: Padding(
        padding: EdgeInsets.only(top: 64.h, left: 20.w, right: 20.w),
        child: Column(
          children: [
            const NextPrayerCard(),
            SizedBox(height: 16.h),
            const DateNavigator(),
            SizedBox(height: 8.h),
            Expanded(
              child: BlocBuilder<PrayerCubit, PrayerState>(
                builder: (context, state) => switch (state) {
                  PrayerInitial() || PrayerLoading() => const AppLoader(),
                  PrayerError(:final message) => AppErrorView(
                      message: message,
                      onRetry: () => context.read<PrayerCubit>().loadPrayers(
                            context.read<SelectedDateCubit>().state.date,
                          ),
                    ),
                  PrayerLoaded(:final prayers, :final date) => Column(
                      children: [
                        PrayerList(prayers: prayers, date: date, now: now),
                      ],
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
