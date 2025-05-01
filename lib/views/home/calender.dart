import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/calender_controller.dart';

class Calendar extends StatelessWidget {
  final DateController dateController = Get.put(DateController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 362.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              dateController.changeDate(-1);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24.sp,
              color: const Color(0xff667085),
            ),
          ),
          Obx(() => Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              dateController.formattedDate,
              style: TextStyle(
                fontFamily: "NotoSans",
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff344054),
              ),
            ),
          )),
          Obx(() => dateController.canIncrementDate()? IconButton(
              onPressed: () {
                dateController.changeDate(1);

              },
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 24.sp,
                color: const Color(0xff667085),
              ),
            ):  SizedBox(height: 24.h,width: 48.w),
          ),
        ],
      ),
    );
  }
}