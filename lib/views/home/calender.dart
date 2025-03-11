import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/text_style.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  @override
  Widget build(BuildContext context) {
    int miladyDate ;
    return Container(
      width: 362.w,
      height: 80.h,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24.sp,
              color: Color(0xff667085),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "24 سبتمبر 2025 ",
                  style: TextStyles.calenderTextMilady,
                ),
              ),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    "20 ربيع الأول 1446هـ‍",
                    style: TextStyles.calenderTextHijry,
                  ))
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 24.sp,
              color: Color(0xff667085),
            ),
          )
        ],
      ),
    );
  }
}
