import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/card_widget_controller.dart';
import '../../resources/colors.dart';
import '../../resources/image_manager.dart';
import '../../resources/text_style.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CardWidgetController controller = Get.put(CardWidgetController());

    return Obx(() => controller.todayPrayerItem.isNotEmpty
        ? Container(
      width: 0.9.sw,
      height: 0.18.sh,
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
              width: 168.w,
              height: 103.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0.h,
            left: 0.w,
            child: Image.asset(
              ImageManger.blackMosque,
              width: 158.w,
              height: 97.h,
              fit: BoxFit.contain,
            ),
          ),
          // النصوص في الأعلى
          Positioned(
            top: 27.h,
            right: 16.w,
            child: SizedBox(
              width: 182.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: ColorManger.brawenColor0,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Obx(() => Text(
                            controller.timeRemaining.value,
                            style: TextStyles.time,
                          )),
                        ),
                      ),
                       SizedBox(width: 1.w),
                      Expanded(
                        child: Obx(() => Text(
                          "سيبدأ ${controller.todayPrayerItem[controller.nextPrayerIndex.value].prayerNameAr} بعد",
                          style: TextStyles.textContainer,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 11.5.h),
                  Obx(() => Text(
                    controller.hijriDate.value,
                    style: TextStyles.textContainer,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.end,
                  )),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                    "${controller.todayPrayerItem[controller.nextPrayerIndex.value].time.hour}:${controller.todayPrayerItem[controller.nextPrayerIndex.value].time.minute.toString().padLeft(2, '0')}",
                    style: TextStyles.bigTime,
                    textAlign: TextAlign.end,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        : Container());
  }
}