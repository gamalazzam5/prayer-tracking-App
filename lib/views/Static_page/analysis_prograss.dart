import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalysisState extends StatelessWidget {
  final Color color;
   double width;

  AnalysisState({
    super.key,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      width: width.w,
      height: 10.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r)),
      ),
    );
  }
}