import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One animated horizontal bar in a [StatusSummaryCard].
class StatusBar extends StatelessWidget {
  final Color color;

  /// The prayer's share of this status, in `[0, 1]`.
  final double share;

  /// Width in logical pixels at share 0 and share 1. A non-zero minimum keeps
  /// empty bars visible as a baseline.
  static const double minWidth = 10;
  static const double maxWidth = 60;

  const StatusBar({super.key, required this.color, required this.share});

  @override
  Widget build(BuildContext context) {
    final target =
        minWidth + (maxWidth - minWidth) * share.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: minWidth, end: target),
      builder: (context, value, _) => Container(
        margin: EdgeInsets.only(bottom: 4.h),
        // `.w` is applied once, here. The previous version scaled the value
        // twice, which made every bar wider than intended on large screens.
        width: value.w,
        height: 10.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
          ),
        ),
      ),
    );
  }
}
