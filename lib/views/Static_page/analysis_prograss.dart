import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedAnalysisState extends StatelessWidget {
  final Color color;
  final double targetWidth;

  const AnimatedAnalysisState({
    super.key,
    required this.color,
    required this.targetWidth,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500), // مدة الحركة السلسة
      curve: Curves.easeInOut, // نوع الحركة
      tween: Tween<double>(begin: 10, end: targetWidth), // من الحد الأدنى إلى العرض المستهدف
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 4.h),
          width: value.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.r),
              bottomRight: Radius.circular(10.r),
            ),
          ),
        );
      },
    );
  }
}