import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// White rounded surface with the app's standard elevation shadow.
/// Replaces the box-decoration blocks that were copy-pasted across screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color color;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.radius = 10,
    this.color = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.r,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: child,
    );
  }
}
