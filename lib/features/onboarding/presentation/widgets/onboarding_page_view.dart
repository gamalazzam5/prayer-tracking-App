import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_page_entity.dart';

/// One full-height intro page: artwork above, RTL copy below.
class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageEntity page;

  const OnboardingPageContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          page.imageAsset,
          width: 1.sw,
          height: 460.h,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 24.h),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(page.title, style: AppTextStyles.screenTitle),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        page.subtitle,
                        style: AppTextStyles.onboardingSubtitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The animated page-position dots.
class OnboardingDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++)
          Padding(
            padding: EdgeInsets.all(5.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index == activeIndex ? 30.w : 14.w,
              height: 14.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.5.r),
                color: index == activeIndex ? activeColor : inactiveColor,
              ),
            ),
          ),
      ],
    );
  }
}
