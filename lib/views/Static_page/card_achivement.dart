import 'package:depi1/resources/image_manager.dart';
import 'package:depi1/resources/text_style.dart';
import 'package:depi1/views/Static_page/statics_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardAchivement extends StatelessWidget {
  const CardAchivement({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final StatisticsService _statisticsService = StatisticsService();

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
          ]),
      width: 362.w,
      height: 108.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: SvgPicture.asset(
                ImageManger.cardAchivemnt,
                width: 85.w,
                height: 72.h,
              ),
            ),
            SizedBox(
              width: 24.w,
            ),
            StreamBuilder<Map<String, dynamic>>(
              stream: _statisticsService.getAchievementStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text("أسبوع مبارك!", style: TextStyles.staticTitle),
                        const SizedBox(height: 12),
                        Text("تقدمك هذا الأسبوع: ٪0", style: TextStyles.staticSubTitle),
                        Text("واصل السعي لتحقيق الأفضل!", style: TextStyles.staticSubTitle),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Text(
                        "أسبوع مبارك!",
                        style: TextStyles.staticTitle,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "تقدمك هذا الأسبوع: ${data['percentage']}",
                        style: TextStyles.staticSubTitle,
                      ),
                      Text(
                        data['message'],
                        style: TextStyles.staticSubTitle,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}