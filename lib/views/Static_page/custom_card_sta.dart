import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../resources/text_style.dart';
import 'analysis_prograss.dart';

class CustomCard extends StatelessWidget {
  final Color color;
  double fajrBar;
  double dhurBar;
  double asrBar;
  double maghribBar;
  double ishaBar;

  final String statusText;
  String percentage;
  String count;
  final String iconUrl;

  CustomCard(
      {super.key,
      required this.color,
      required this.fajrBar,
      required this.statusText,
      required this.percentage,
      required this.count,
      required this.iconUrl,
      required this.dhurBar,
      required this.asrBar,
      required this.maghribBar,
      required this.ishaBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            blurRadius: 4,
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      width: 173.w,
      height: 112.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnalysisState(
                color: color,
                width: fajrBar.w,
              ),
              AnalysisState(
                color: color,
                width: dhurBar.w,
              ),
              AnalysisState(
                color: color,
                width: asrBar.w,
              ),
              AnalysisState(
                color: color,
                width: maghribBar.w,
              ),
              AnalysisState(
                color: color,
                width: ishaBar.w,
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0.h),
                    child: Text(
                      statusText,
                      style: TextStyles.staticsStyleText,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    percentage,
                    style: TextStyles.staticsStyleText,
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    count,
                    style: TextStyles.staticsStyleText,
                    textDirection: TextDirection.rtl,
                  )
                ],
              ),
              SizedBox(width: 7.w),
              Padding(
                padding: EdgeInsets.only(top: 16.0.h, right: 10.w),
                child: SvgPicture.asset(
                  iconUrl,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
