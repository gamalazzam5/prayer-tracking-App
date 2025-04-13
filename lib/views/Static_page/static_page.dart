import 'package:depi1/resources/image_manager.dart';
import 'package:depi1/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card_achivement.dart';
import 'custom_card_sta.dart';

class StaticPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double miniBarValue = 10;
    const double maxBarValue = 60;

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Text("الاحصائيات", style: TextStyles.titleBoarding),
            SizedBox(height: 32.h),
            ListTile(
              leading: InkWell(
                onTap: () {},
                child: Image.asset(
                  ImageManger.settingIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              title: Text(
                "إحصائيات الصلوات",
                style: TextStyles.titleBoarding,
                textDirection: TextDirection.rtl,
              ),
              trailing: Image.asset(
                ImageManger.analysisStatic,
                width: 24,
                height: 24,
              ),
            ),
            CardAchivement(),
            SizedBox(height: 16.h),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("مُلخّص التقدم", style: TextStyles.staticTile0),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0.w, top: 16.h),
                  child: Column(
                    children: [
                      CustomCard(
                        color: Color(0xffCF9C00),
                        fajrBar: ((60 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        dhurBar: ((20 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        asrBar: ((30 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        maghribBar: ((4 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        ishaBar: ((120 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        statusText: "متأخرا",
                        //n.of prayer late/ totalPrayer *100
                        percentage: "20%",
                        count: "40 مره",
                        iconUrl: ImageManger.lateIcon,
                      ),
                      SizedBox(height: 12.h),
                      CustomCard(
                        iconUrl: ImageManger.gama3aIcon,
                        color: Color(0xff26B765),
                        fajrBar: ((2 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        dhurBar: ((10 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        asrBar: ((1 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        maghribBar: ((50 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        ishaBar: ((100 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        statusText: "جماعه",
                        //n.of prayer Gam3a/ totalPrayer *100
                        percentage: "70%",
                        count: "150 مره",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0.w, top: 16.0.h),
                  child: Column(
                    children: [
                      CustomCard(
                        color: Color(0xffC92B2B),
                        fajrBar: ((44 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        dhurBar: ((33 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        asrBar: ((22 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        maghribBar: ((100 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        ishaBar: ((13 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        statusText: "لم اصلي",
                        //n.of prayer Gam3a/ totalPrayer *100
                        percentage: "5%",
                        count: "10 مره",
                        iconUrl: ImageManger.slashIcon,
                      ),
                      SizedBox(height: 12.h),
                      CustomCard(
                        iconUrl: ImageManger.aloneIcon,
                        color: Color(0xff248DDE),
                        fajrBar: ((55 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        dhurBar: ((44 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        asrBar: ((22 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        maghribBar: ((56 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        ishaBar: ((45 / 100) * maxBarValue)
                            .clamp(miniBarValue, maxBarValue),
                        statusText: "منفردا",
                        //n.of prayer alone/ totalPrayer *100
                        percentage: "10%",
                        count: "10 مره",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
