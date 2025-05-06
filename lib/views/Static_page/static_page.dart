import 'package:depi1/resources/image_manager.dart';
import 'package:depi1/resources/text_style.dart';
import 'package:depi1/views/Static_page/statics_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card_achivement.dart';
import 'custom_card_sta.dart';

class StaticPage extends StatelessWidget {
  final StatisticsService _statisticsService = StatisticsService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: StreamBuilder<Map<String, Map<String, dynamic>>>(
          stream: _statisticsService.getStatisticsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data!;

            return Column(
              children: [
                SizedBox(height: 16.h),
                Text("الاحصائيات", style: TextStyles.titleBoarding),
                SizedBox(height: 32.h),
                ListTile(

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
                            color: const Color(0xffCF9C00),
                            fajrBar: stats["متأخر"]!["fajrBar"],
                            dhurBar: stats["متأخر"]!["dhurBar"],
                            asrBar: stats["متأخر"]!["asrBar"],
                            maghribBar: stats["متأخر"]!["maghribBar"],
                            ishaBar: stats["متأخر"]!["ishaBar"],
                            statusText: "متأخرا",
                            percentage: stats["متأخر"]!["percentage"],
                            count: stats["متأخر"]!["count"],
                            iconUrl: ImageManger.lateIcon,
                          ),
                          SizedBox(height: 12.h),
                          CustomCard(
                            iconUrl: ImageManger.gama3aIcon,
                            color: const Color(0xff26B765),
                            fajrBar: stats["جماعه"]!["fajrBar"],
                            dhurBar: stats["جماعه"]!["dhurBar"],
                            asrBar: stats["جماعه"]!["asrBar"],
                            maghribBar: stats["جماعه"]!["maghribBar"],
                            ishaBar: stats["جماعه"]!["ishaBar"],
                            statusText: "جماعه",
                            percentage: stats["جماعه"]!["percentage"],
                            count: stats["جماعه"]!["count"],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0.w, top: 16.0.h),
                      child: Column(
                        children: [
                          CustomCard(
                            color: const Color(0xffC92B2B),
                            fajrBar: stats["لم اصلي"]!["fajrBar"],
                            dhurBar: stats["لم اصلي"]!["dhurBar"],
                            asrBar: stats["لم اصلي"]!["asrBar"],
                            maghribBar: stats["لم اصلي"]!["maghribBar"],
                            ishaBar: stats["لم اصلي"]!["ishaBar"],
                            statusText: "لم اصلي",
                            percentage: stats["لم اصلي"]!["percentage"],
                            count: stats["لم اصلي"]!["count"],
                            iconUrl: ImageManger.slashIcon,
                          ),
                          SizedBox(height: 12.h),
                          CustomCard(
                            iconUrl: ImageManger.aloneIcon,
                            color: const Color(0xff248DDE),
                            fajrBar: stats["منفردا"]!["fajrBar"],
                            dhurBar: stats["منفردا"]!["dhurBar"],
                            asrBar: stats["منفردا"]!["asrBar"],
                            maghribBar: stats["منفردا"]!["maghribBar"],
                            ishaBar: stats["منفردا"]!["ishaBar"],
                            statusText: "منفردا",
                            percentage: stats["منفردا"]!["percentage"],
                            count: stats["منفردا"]!["count"],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}