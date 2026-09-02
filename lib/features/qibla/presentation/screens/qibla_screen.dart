import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../cubit/qibla_cubit.dart';
import '../cubit/qibla_state.dart';
import '../widgets/qibla_compass.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Text('القِبْلَة', style: AppTextStyles.screenTitle),
            Expanded(
              child: BlocBuilder<QiblaCubit, QiblaState>(
                builder: (context, state) => switch (state) {
                  QiblaInitial() || QiblaLoading() => const AppLoader(),
                  QiblaReady(:final direction) =>
                    QiblaCompass(direction: direction),
                  QiblaError(:final message, :final isRecoverable) =>
                    AppErrorView(
                      message: message,
                      icon: isRecoverable
                          ? Icons.location_off
                          : Icons.explore_off,
                      onRetry: isRecoverable
                          ? context.read<QiblaCubit>().start
                          : null,
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
