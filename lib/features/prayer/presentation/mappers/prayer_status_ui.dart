import 'package:flutter/material.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_status.dart';

/// Presentation-only mapping from domain enums to labels, colours and assets.
/// Keeping it here is what lets the domain layer stay free of Flutter.
extension PrayerStatusUi on PrayerStatus {
  String get label => switch (this) {
        PrayerStatus.missed => 'لم اصلي',
        PrayerStatus.late => 'متأخر',
        PrayerStatus.alone => 'منفردا',
        PrayerStatus.congregation => 'جماعه',
      };

  /// Wording used in the picker, which is phrased as a full sentence.
  String get pickerLabel => switch (this) {
        PrayerStatus.missed => 'لم اصلي',
        PrayerStatus.late => 'صليت متأخر',
        PrayerStatus.alone => 'صليت منفردا',
        PrayerStatus.congregation => 'صليت في جماعه',
      };

  Color get color => switch (this) {
        PrayerStatus.missed => AppColors.statusMissed,
        PrayerStatus.late => AppColors.statusLate,
        PrayerStatus.alone => AppColors.statusAlone,
        PrayerStatus.congregation => AppColors.greenDark,
      };

  /// Colour used for the statistics bars, where congregation reads better in
  /// the brighter green.
  Color get chartColor => switch (this) {
        PrayerStatus.congregation => AppColors.statusCongregation,
        _ => color,
      };

  String get iconAsset => switch (this) {
        PrayerStatus.missed => AppAssets.missedIcon,
        PrayerStatus.late => AppAssets.lateIcon,
        PrayerStatus.alone => AppAssets.aloneIcon,
        PrayerStatus.congregation => AppAssets.congregationIcon,
      };
}

extension PrayerNameUi on PrayerName {
  String get iconAsset => switch (this) {
        PrayerName.fajr => AppAssets.fajrIcon,
        PrayerName.dhuhr => AppAssets.dhuhrIcon,
        PrayerName.asr => AppAssets.asrIcon,
        PrayerName.maghrib => AppAssets.maghribIcon,
        PrayerName.isha => AppAssets.ishaIcon,
      };
}
