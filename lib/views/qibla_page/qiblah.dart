import 'dart:math' as math;
import 'package:depi1/resources/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/qibla_controller.dart';
import '../../resources/text_style.dart';

class QiblaCompass extends StatelessWidget {
  final QiblaController controller = Get.put(QiblaController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "القِبْلَة",
              style: TextStyles.titleBoarding,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 100.h),
            Obx(() {
              double rotation = controller.direction.value - controller.qiblaDirection.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    ImageManger.qiblaImage0,
                    width: 300.w,
                    height: 400.h,
                  ),
                  Transform.rotate(
                    angle: rotation * (math.pi / 180),
                    child: SvgPicture.asset(
                      ImageManger.directionQibla,
                      width: 150.w,
                      height: 200.h,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 40.h),
            Text(
              "اقتربت من القبلة، قم بتعديل الاتجاه قليلًا.",
              style: TextStyles.qiblaTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
