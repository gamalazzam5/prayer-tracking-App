import 'dart:math' show pi, min;

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

  /// Largest side the dial is allowed to take when there is room to spare.
  static const double _maxDialSize = 320;

  const QiblaCompass({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Square dial sized to the smaller side so it stays fully visible and
        // exactly centred on any screen.
        final size = min(
          min(constraints.maxWidth, constraints.maxHeight),
          _maxDialSize.r,
        );

        // The hint is overlaid rather than stacked in a Column so it cannot
        // push the dial off the centre of the available area.
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // AnimatedRotation smooths out raw magnetometer jitter,
                    // which otherwise makes the dial visibly twitch.
                    AnimatedRotation(
                      turns: -direction.deviceHeading / 360,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        AppAssets.qiblaDial,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Transform.rotate(
                      angle: direction.offsetFromDevice * pi / 180,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppAssets.qiblaNeedle,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _AlignmentHint(offset: direction.offsetFromDevice),
            ),
          ],
        );
      },
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
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyBold.copyWith(
            color: isAligned ? AppColors.green : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${delta.round()}°',
          textAlign: TextAlign.center,
          style: AppTextStyles.dateLabel.copyWith(
            color: isAligned ? AppColors.green : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
