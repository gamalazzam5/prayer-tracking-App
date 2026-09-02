import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _arabic = 'Tajawal';
  static const String _latin = 'NotoSans';

  static TextStyle get screenTitle => TextStyle(
        fontFamily: _arabic,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get onboardingSubtitle => TextStyle(
        fontFamily: _arabic,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.green,
      );

  static TextStyle get skip => TextStyle(
        fontFamily: _arabic,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get onCard => TextStyle(
        fontFamily: _arabic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get prayerNameAr => TextStyle(
        fontFamily: _arabic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      );

  static TextStyle get dialogTitle => TextStyle(
        fontFamily: _arabic,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.green,
      );

  static TextStyle get sectionTitle => TextStyle(
        fontFamily: _arabic,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.greenDark,
      );

  static TextStyle get bodyBold => TextStyle(
        fontFamily: _arabic,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get onAccent => TextStyle(
        fontFamily: _arabic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      );

  static TextStyle get navLabel => TextStyle(
        fontFamily: _arabic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.navUnselected,
      );

  static TextStyle get statusLabel => TextStyle(
        fontFamily: _arabic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get clock => TextStyle(
        fontFamily: _latin,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get prayerNameEn => TextStyle(
        fontFamily: _latin,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get bigClock => TextStyle(
        fontFamily: _latin,
        fontSize: 30.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get dateLabel => TextStyle(
        fontFamily: _latin,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      );

  static TextStyle get splashTitle => TextStyle(
        fontFamily: 'Amiri',
        fontSize: 39.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.green,
      );

  static TextStyle get tileTime => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      );
}
