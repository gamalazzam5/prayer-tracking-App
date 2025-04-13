import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/card_widget_controller.dart';
import '../../resources/colors.dart';
import '../../resources/image_manager.dart';
import '../../resources/text_style.dart';
import 'package:depi1/models/prayers_model.dart';

class CardWidget extends StatelessWidget {
  final List<PrayerModel> prayerItem;

  const CardWidget({super.key, required this.prayerItem});

  @override
  Widget build(BuildContext context) {
    final CardWidgetController controller =
        Get.put(CardWidgetController(prayerItem: prayerItem));

    return Container(
      width: 0.9.sw,
      height: .18.sh,
      decoration: BoxDecoration(
        color: ColorManger.greenColor0,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 0.h,
              left: 23.w,
              child: Image.asset(ImageManger.whiteMosque,
                  width: 158.w, height: 97.h)),
          Positioned(
              bottom: 0.h,
              left: 0.w,
              child: Image.asset(ImageManger.blackMosque,
                  width: 168.w, height: 103.h)),
          Positioned(
            top: 27.h,
            right: 16.w,
            child: SizedBox(
              width: 254.w,
              height: 101.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                        child: Center(
                          child: Obx(() => Text(controller.timeRemaining.value,
                              style: TextStyles.time),),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Obx(() => Text(
                          "سيبدأ ${prayerItem[controller.nextPrayerIndex.value].prayerNameAr} بعد",
                          style: TextStyles.textContainer)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Obx(() => Text(controller.hijriDate.value,
                      style: TextStyles.textContainer,
                      textDirection: TextDirection.rtl)),
                  Obx(() => Text(
                        "${prayerItem[controller.nextPrayerIndex.value].time.hour}:${prayerItem[controller.nextPrayerIndex.value].time.minute.toString().padLeft(2, '0')}",
                        style: TextStyles.bigTime,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
