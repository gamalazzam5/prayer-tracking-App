import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../resources/colors.dart';

class AlertBuildContainer extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final String text;
  final String image;

  AlertBuildContainer(
      {super.key,
        required this.onTap,
        required this.isSelected,
        required this.text,
        required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270.w,
        height: 40.h,
        decoration: BoxDecoration(
            color:
            isSelected ? ColorManger.greenColor0 : ColorManger.primaryColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Color(0xffDBE9E5), width: 1.0.w)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: "Tajawal",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : ColorManger.blackColor1,
              ),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(right: 8.0.w),
              child: SvgPicture.asset(
                image,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}