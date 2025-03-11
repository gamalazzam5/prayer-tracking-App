import 'package:depi1/views/home/calender.dart';
import 'package:depi1/views/home/card_widget.dart';
import 'package:depi1/views/home/list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Color(0xffFAF8F2),
      body:  Padding(
          padding: EdgeInsets.only(top: 64.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                CardWidget(),
                SizedBox(height: 16.h),
                Calender(),
                SizedBox(height: 8.h),
                ListViewItems()
              ],
            ),
          ),
        ),
      );
  }
}
