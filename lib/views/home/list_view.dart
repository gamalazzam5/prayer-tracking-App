import 'package:depi1/views/home/prayerCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class ListViewItems extends StatelessWidget {
  const ListViewItems({super.key});

  @override
  Widget build(BuildContext context) {

    return  Expanded(
      child: Container(

        decoration:  BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.r),
                topLeft: Radius.circular(10.r),),),
        child: ListView.builder(
          padding:  EdgeInsets.only(top: 10.h,right: 10.w,left: 10.w),
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                PrayerCategory( index: index,),

                 SizedBox(height: 8.h),
                // Space between items
              ],
            );
          },
        ),
      ),
    );
  }
}
