import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/prayers_model.dart';
import '../../resources/colors.dart';
import '../../resources/image_manager.dart';
import '../../resources/text_style.dart';

class PrayerCategory extends StatefulWidget {
  final int index;

  PrayerCategory({super.key, required this.index});

  @override
  State<PrayerCategory> createState() => _PrayerCategoryState();
}

class _PrayerCategoryState extends State<PrayerCategory> {
  final List<PrayerModel> prayerItem = [
    PrayerModel(
        time: DateTime(2025, 3, 6, 4, 45),
        status: "",
        iconStatusUrl: ImageManger.aloneIcon,
        prayerNameAr: "الفجر",
        prayerNameEN: "Fajr",
        iconWeatherUrl: ImageManger.fajrIcon,
        amOrPm: ' AM',
        prayerIcon: ImageManger.fajrIcon),

    PrayerModel(
        time: DateTime(2025, 3, 6, 12, 15),
        status: "",
        iconStatusUrl: ImageManger.slashIcon,
        prayerNameAr: "الظهر",
        prayerNameEN: "Dhuhr",
        iconWeatherUrl: ImageManger.duhurIcon,
        amOrPm: ' PM',
        prayerIcon: ImageManger.duhurIcon),
    PrayerModel(
        time: DateTime(2025, 3, 6, 3, 30),
        status: "",
        iconStatusUrl: ImageManger.lateIcon,
        prayerNameAr: "العصر",
        prayerNameEN: "Asr",
        iconWeatherUrl: ImageManger.shurukAndAsrIcon,
        amOrPm: ' PM',
        prayerIcon: ImageManger.shurukAndAsrIcon),
    PrayerModel(
        time: DateTime(2025, 3, 6, 5, 45),
        status: "",
        iconStatusUrl: ImageManger.slashIcon,
        prayerNameAr: "المغرب",
        prayerNameEN: "Maghrib",
        iconWeatherUrl: ImageManger.maghribIcon,
        amOrPm: ' PM',
        prayerIcon: ImageManger.maghribIcon),
    PrayerModel(
        time: DateTime(2025, 3, 6, 7, 12),
        status: "",
        iconStatusUrl: ImageManger.aloneIcon,
        prayerNameAr: "العشاء",
        prayerNameEN: "Isha",
        iconWeatherUrl: ImageManger.ishaIcon,
        amOrPm: ' PM',
        prayerIcon: ImageManger.ishaIcon),
    PrayerModel(
        time: DateTime(2025, 3, 6, 5, 45),
        status: "",
        iconStatusUrl: ImageManger.gama3aIcon,
        prayerNameAr: "الشروق",
        prayerNameEN: "Shuruk",
        iconWeatherUrl: ImageManger.shurukAndAsrIcon,
        amOrPm: ' AM',
        prayerIcon: ImageManger.shurukAndAsrIcon),
  ];

  @override
  Widget build(BuildContext context) {
    //here i need to edit and solve logical error .(عاوز اخلي مثلا احذف الاندكس الي عديت عليه بحيث ميفضلش واقف عل الفجر)
    DateTime now = DateTime.now();
    int nextPrayerIndex = -1;
    for (int i = 0; i < prayerItem.length; i++) {
      if(prayerItem[widget.index].amOrPm == ' PM' && now.isBefore(prayerItem[widget.index].time)){

        nextPrayerIndex = i;

        break;
      } else if(prayerItem[widget.index].amOrPm == ' AM' && now.isAfter(prayerItem[widget.index].time) ) {
        nextPrayerIndex =i;
    break;
    }
      //else nextPrayerIndex=-1;

    }
    if (nextPrayerIndex == -1) {
      nextPrayerIndex = 0;
    }
    bool showNextPrayer = (widget.index == nextPrayerIndex);

    return Container(
      width: 342.w,
      height: 88.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: showNextPrayer ? Color(0xff9B7B30) : Color(0xffffffff),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0.r, 0.r),
              blurRadius: 4.r,
              spreadRadius: 0.r)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding:  EdgeInsets.only(left: 8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        "${prayerItem[widget.index].time.hour}:${prayerItem[widget.index].time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: showNextPrayer
                                ? Color(0xff141417)
                                : Color(0xff667085)),
                      ),
                      Text(
                        prayerItem[widget.index].amOrPm,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: showNextPrayer
                                ? Color(0xff141417)
                                : Color(0xff667085)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Container(
                  width: 95.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Color(0xffE7F1EE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: showNextPrayer
                      ? Container(
                          width: 95.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Color(0xff1E5B4A),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "استعد للصلاه",
                                style: TextStyles.registerStyle,
                              ),
                              //SvgPicture.asset(ImageManger.notAvailable,width: 18,height: 23,color: ColorManger.primaryColor,)
                            ],
                          ),
                        )
                  //here condition will be  if index of selectedPrayer > here index
                      : GestureDetector(

                          onTap: () => showDialog(context: context,builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              title: Text(
                                "كيف صليت ${prayerItem[widget.index].prayerNameAr} اليوم ؟ ",
                                style: TextStyles.prayerNameAr1,
                              ),

                            );
                          } ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                prayerItem[widget.index].status,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Tajawal",
                                    color: prayerItem[widget.index].status ==
                                            "منفردا"
                                        ? Color(0xff248DDE)
                                        : prayerItem[widget.index].status ==
                                                "لم اصلي"
                                            ? Color(0xffC92B2B)
                                            : prayerItem[widget.index].status ==
                                                    "متأخر"
                                                ? Color(0xffCF9C00)
                                                : prayerItem[widget.index]
                                                            .status ==
                                                        "جماعه"
                                                    ? Color(0xff1E5B4A)
                                                    : ColorManger.blackColor1),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              SvgPicture.asset(
                                prayerItem[widget.index].iconStatusUrl,
                                color: prayerItem[widget.index].status ==
                                        "منفردا"
                                    ? Color(0xff248DDE)
                                    : prayerItem[widget.index].status ==
                                            "لم اصلي"
                                        ? Color(0xffC92B2B)
                                        : prayerItem[widget.index].status ==
                                                "متأخر"
                                            ? Color(0xffCF9C00)
                                            : prayerItem[widget.index].status ==
                                                    "جماعه"
                                                ? Color(0xff1E5B4A)
                                                : Colors.transparent,
                                width: 24.w,
                                height: 24.h,
                              ),
                            ],
                          ),
                        ),
                )
              ],
            ),
          ),
          //----------right section of Icons -------------\\
          Padding(
            padding:  EdgeInsets.only(right: 10.w),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prayerItem[widget.index].prayerNameAr,
                      style: TextStyle(
                          fontFamily: "Tajawal",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: showNextPrayer
                              ? Color(0xff141417)
                              : ColorManger.blackColor2),
                    ),
                    Text(
                      prayerItem[widget.index].prayerNameEN,
                      style: TextStyle(
                          fontFamily: "NotoSans",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: showNextPrayer
                              ? Color(0xff141417)
                              : Color(0xff98A2B3)),
                    ),
                  ],
                ),
                SizedBox(
                  width: 6.w,
                ),
                Image.asset(
                  prayerItem[widget.index].iconWeatherUrl,
                  width: 48.w,
                  height: 48.h,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
