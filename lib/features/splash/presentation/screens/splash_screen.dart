import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is! SplashReady) return;
        final route = switch (state.destination) {
          SplashDestination.home => AppRoutes.home,
          SplashDestination.onboarding => AppRoutes.onboarding,
        };
        // The listener only fires while this screen is mounted, so the
        // "navigate after dispose" crash the timer-based version could hit is
        // not reachable here.
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.splash, height: 187.h, width: 250.w),
              SizedBox(height: 16.h),
              Text(
                'صلاتك أولاً',
                textAlign: TextAlign.center,
                style: AppTextStyles.splashTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
