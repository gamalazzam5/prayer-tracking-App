import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/qibla_direction_entity.dart';

/// The rotating dial and needle.
///
/// The dial counter-rotates by the device heading so its north mark keeps
/// pointing at true north; the needle rotates by the qibla's offset from the
/// device heading, so it always points at the Kaaba.
class QiblaCompass extends StatelessWidget {
  final QiblaDirectionEntity direction;

  const QiblaCompass({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AlignmentHint(offset: direction.offsetFromDevice),
        SizedBox(height: 16.h),
        SizedBox(
          height: 320.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // AnimatedRotation smooths out raw magnetometer jitter, which
              // otherwise makes the dial visibly twitch.
              AnimatedRotation(
                turns: -direction.deviceHeading / 360,
                duration: const Duration(milliseconds: 200),
                child: SvgPicture.asset(
                  AppAssets.qiblaDial,
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
              ),
              Transform.rotate(
                angle: direction.offsetFromDevice * pi / 180,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AppAssets.qiblaNeedle,
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tells the user how close the device is to facing the qibla.
class _AlignmentHint extends StatelessWidget {
  final double offset;

  /// Within this many degrees the device counts as facing the qibla.
  static const double _toleranceDegrees = 5;

  const _AlignmentHint({required this.offset});

  @override
  Widget build(BuildContext context) {
    // Shortest angular distance from 0°, so 358° reads as 2° off, not 358°.
    final delta = offset > 180 ? 360 - offset : offset;
    final isAligned = delta <= _toleranceDegrees;

    return Column(
      children: [
        Text(
          isAligned ? 'أنت تواجه القبلة' : 'أدر جهازك ناحية السهم',
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyBold.copyWith(
            color: isAligned ? AppColors.green : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${delta.round()}°',
          style: AppTextStyles.dateLabel.copyWith(
            color: isAligned ? AppColors.green : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
