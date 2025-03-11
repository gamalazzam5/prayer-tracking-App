import 'package:depi1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/colors.dart';
import '../../resources/image_manager.dart';
import '../../resources/text_style.dart';

class CardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
        width: 0.9.sw
        ,height: .18.sh,
        decoration: BoxDecoration(
          color: ColorManger.greenColor0,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0.h,
              left: 23.w,
              child: Image.asset(
                ImageManger.whiteMosque,
                width: 158.w,
                height: 97.h,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0.h,
              left: 0.w,
              child: Image.asset(
                ImageManger.blackMosque,
                width: 168.w,
                height: 103.h,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 27.h,
              right: 16.w,
              child: Container(
                width: 254.w,
                height: 101.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align text to the right
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 75.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: ColorManger.brawenColor0,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Center( // Center the text in the container
                            child: Text(
                              "00:37:25",
                              style: TextStyles.time,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.5.w),
                        Text(
                          "سيبدأ المغرب بعد",
                          style: TextStyles.textContainer,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "20 ربيع الأول 1446 هـ‍",
                      style: TextStyles.textContainer,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      "17:21",
                      style: TextStyles.bigTime,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  }

}