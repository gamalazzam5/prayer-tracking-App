import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';


class TextStyles {

  TextStyles._();

  static TextStyle titleBoarding = TextStyle(
    fontFamily: "Tajawal", fontSize: 20.sp, fontWeight: FontWeight.w700,
    color: ColorManger.blackColor1

  );

  static TextStyle subtitleBoarding = TextStyle(
    fontFamily: "Tajawal", fontSize: 16.sp, fontWeight: FontWeight.w700,color: ColorManger.greenColor);

static TextStyle skipStyle = TextStyle(
    fontFamily: "Tajawal", fontSize: 17.sp, fontWeight: FontWeight.w600,
    color: ColorManger.blackColor1

);
  static TextStyle qiblaTextStyle = TextStyle(
      fontFamily: "Tajawal", fontSize: 16.sp, fontWeight: FontWeight.w700,color: ColorManger.yellowColor);

  static TextStyle textContainer = TextStyle(
      fontFamily: "Tajawal", fontSize: 14.sp, fontWeight: FontWeight.w700,color: ColorManger.primaryColor);

  static TextStyle prayerNameAr = TextStyle(
      fontFamily: "Tajawal", fontSize: 14.sp, fontWeight: FontWeight.w700,color: ColorManger.blackColor2);
  static TextStyle prayerNameAr1 = TextStyle(
      fontFamily: "Tajawal", fontSize: 18.sp, fontWeight: FontWeight.w700,color: ColorManger.greenColor);
  static TextStyle bottomNavTextSelceted = TextStyle(
      fontFamily: "Tajawal", fontSize: 14.sp, fontWeight: FontWeight.w500,color: ColorManger.greenColor0);
  static TextStyle staticTitle = TextStyle(
      fontFamily: "Tajawal", fontSize: 20.sp, fontWeight: FontWeight.w700,color: ColorManger.greenColor0);
  static TextStyle staticSubTitle = TextStyle(
      fontFamily: "Tajawal", fontSize: 16.sp, fontWeight: FontWeight.w700,color: ColorManger.blackColor1);
  static TextStyle staticTile0 = TextStyle(
      fontFamily: "Tajawal", fontSize: 20.sp, fontWeight: FontWeight.w700,color: ColorManger.blackColor1);
  static TextStyle registerStyle = TextStyle(
      fontFamily: "Tajawal", fontSize: 14.sp, fontWeight: FontWeight.w500,color: ColorManger.primaryColor);
  static TextStyle bottomNavTextUnSelceted = TextStyle(
      fontFamily: "Tajawal", fontSize: 14.sp, fontWeight: FontWeight.w500,color: const Color(0xff8789A3));
  static TextStyle staticsStyleText = TextStyle(
      fontFamily: "Tajawal", fontSize: 18.sp, fontWeight: FontWeight.w700,color: ColorManger.blackColor1);
  static TextStyle time = TextStyle(
      fontFamily: "NotoSans", fontSize: 14.sp, fontWeight: FontWeight.w600,
      color: ColorManger.primaryColor

  );
  static TextStyle prayerNameEn = TextStyle(
      fontFamily: "NotoSans", fontSize: 14.sp, fontWeight: FontWeight.w500,
      color:const Color(0xff98A2B3)

  );
  static TextStyle bigTime = TextStyle(
      fontFamily: "NotoSans", fontSize: 30.sp, fontWeight: FontWeight.w600,
      color: ColorManger.primaryColor

  );
  // static TextStyle calenderTextMilady = TextStyle(
  //     fontFamily: "NotoSans", fontSize: 16.sp, fontWeight: FontWeight.bold,
  //     color:const Color(0xff344054)
  //
  // );
  static TextStyle calenderTextHijry = TextStyle(
      fontFamily: "NotoSans", fontSize: 14.sp, fontWeight: FontWeight.w400,
      color:const Color(0xff344054)

  );


}