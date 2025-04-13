import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../resources/colors.dart';
import '../views/Static_page/static_page.dart';
import '../views/home/home.dart';
import '../views/qibla_page/qiblah.dart';

class HomeViewController extends GetxController {
  int myIndex = 0;

  final List<Widget> screens = [
    HomePage(),
    QiblaCompass(),
    StaticPage(),
    Container(),
  ];

  final List<Map<String, dynamic>> navItems = [
    {"icon": "mosque.png", "label": "الرئيسية"},
    {"icon": "kaaba.png", "label": "القِبْلَة"},
    {"icon": "statics.png", "label": "الإحصائيات"},
    {"icon": Icons.settings, "label": "الإعدادات"},
  ];

  ///here i will use GetBuilder as i didn't use Stream and it more faster and lower Memory
  void onItemTapped(int index) {
    if (myIndex != index) {
      myIndex = index;
      update();
    }
  }

  List<BottomNavigationBarItem> buildNavItems() {
    return List.generate(
      navItems.length,
      (index) {
        return BottomNavigationBarItem(
          icon: index == 3
              ? Icon(navItems[index]['icon'],
                  size: 24.sp,
                  color: myIndex == index
                      ? ColorManger.greenColor
                      : const Color(0xff8789A3))
              : Image.asset("assets/images/icons/${navItems[index]['icon']}",
                  height: 24.h,
                  width: 24.w,
                  color: myIndex == index
                      ? ColorManger.greenColor
                      : const Color(0xff8789A3)),
          label: navItems[index]['label'],
        );
      },
    );
  }
}
