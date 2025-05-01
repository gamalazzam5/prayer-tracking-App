import 'package:depi1/views/home/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/calender_controller.dart';
import '../../models/prayers_model.dart';
import '../../resources/colors.dart';
import '../../resources/text_style.dart';

class PrayerCategory extends StatefulWidget {
  final int index;
  final List<PrayerModel> prayerItem;

  PrayerCategory({super.key, required this.index, required this.prayerItem});

  @override
  State<PrayerCategory> createState() => _PrayerCategoryState();
}

class _PrayerCategoryState extends State<PrayerCategory> {
  bool showNextPrayer = false;
  final DateController dateController = Get.find<DateController>();

  @override
  void initState() {
    super.initState();
    _updateNextPrayer();
    ever(dateController.selectedDate, (_) => _updateNextPrayer());
  }

  void _updateNextPrayer() {
    DateTime now = DateTime.now();
    DateTime selectedDate = dateController.selectedDate.value;
    int nextPrayerIndex = -1;

    bool isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (isToday) {
      for (int i = 0; i < widget.prayerItem.length; i++) {
        if (now.isBefore(widget.prayerItem[i].time)) {
          nextPrayerIndex = i;
          break;
        }
      }
    }

    setState(() {
      showNextPrayer = isToday && (widget.index == nextPrayerIndex);
    });
  }

  void _handleStatusChange(String status, String icon) {
    setState(() {
      widget.prayerItem[widget.index].status = status;
      widget.prayerItem[widget.index].iconStatusUrl = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342.w,
      height: 88.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: showNextPrayer ? const Color(0xff9B7B30) : const Color(0xffffffff),
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
            padding: EdgeInsets.only(left: 8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        "${widget.prayerItem[widget.index].time.hour}:${widget.prayerItem[widget.index].time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: showNextPrayer
                                ? const Color(0xff141417)
                                : const Color(0xff667085)),
                      ),
                      Text(
                        widget.prayerItem[widget.index].amOrPm,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: showNextPrayer
                                ? const Color(0xff141417)
                                : const Color(0xff667085)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {
                    DateTime now = DateTime.now();
                    DateTime selectedDate = dateController.selectedDate.value;
                    // Check if the selected date is today
                    bool isToday = selectedDate.year == now.year &&
                        selectedDate.month == now.month &&
                        selectedDate.day == now.day;

                    // If it's today, only allow status change for past prayers
                    // If it's a past date, allow status change for all prayers
                    if (!isToday || widget.prayerItem[widget.index].time.isBefore(now)) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog(
                            prayerItem: widget.prayerItem,
                            widget: widget,
                            onStatusChange: _handleStatusChange,
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    width: 95.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffE7F1EE),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: showNextPrayer
                        ? Container(
                      width: 95.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: const Color(0xff1E5B4A),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "استعد للصلاه",
                            style: TextStyles.registerStyle,
                          ),
                        ],
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.prayerItem[widget.index].status,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Tajawal",
                              color: widget.prayerItem[widget.index].status ==
                                  "منفردا"
                                  ? const Color(0xff248DDE)
                                  : widget.prayerItem[widget.index].status ==
                                  "لم اصلي"
                                  ? const Color(0xffC92B2B)
                                  : widget.prayerItem[widget.index].status ==
                                  "متأخر"
                                  ? const Color(0xffCF9C00)
                                  : widget.prayerItem[widget.index].status ==
                                  "جماعه"
                                  ? const Color(0xff1E5B4A)
                                  : ColorManger.blackColor1),
                        ),
                        SizedBox(width: 5.w),
                        SvgPicture.asset(
                          widget.prayerItem[widget.index].iconStatusUrl,
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
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.prayerItem[widget.index].prayerNameAr,
                      style: TextStyle(
                          fontFamily: "Tajawal",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: showNextPrayer
                              ? const Color(0xff141417)
                              : ColorManger.blackColor2),
                    ),
                    Text(
                      widget.prayerItem[widget.index].prayerNameEN,
                      style: TextStyle(
                          fontFamily: "NotoSans",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: showNextPrayer
                              ? const Color(0xff141417)
                              : const Color(0xff98A2B3)),
                    ),
                  ],
                ),
                SizedBox(width: 6.w),
                Image.asset(
                  widget.prayerItem[widget.index].iconWeatherUrl,
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