import 'package:depi1/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../resources/colors.dart';
import '../resources/text_style.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int myIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    Container(),
    Container(),
    Container(),

  ];
  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xffFAF8F2),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/pattern.png'),
                fit: BoxFit.cover,
                opacity: .07),
          ),
          child: _screens[myIndex]),
      bottomNavigationBar: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
      child: Container(
        height: 87.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 15.r,
              spreadRadius: 0.r,
            ),
          ],
        ),
        child: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          currentIndex: myIndex,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/icons/mosque.png",
                height: 24.h,
                width: 24.w,
                color: myIndex == 0 ? ColorManger.greenColor : Color(0xff8789A3),
              ),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/icons/kaaba.png",
                  height: 24.h,
                  width: 24.w,
                  color:
                  myIndex == 1 ? ColorManger.greenColor : Color(0xff8789A3),
                ),
                label: "القِبْلَة"),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/icons/statics.png",
                  height: 24.h,
                  width: 24.w,
                  color:
                  myIndex == 2 ? ColorManger.greenColor : Color(0xff8789A3),
                ),
                label: "الاحصائيات"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 24.sp,
                  color:
                  myIndex == 3 ? ColorManger.greenColor : Color(0xff8789A3),
                ),
                label: "الإعدادات"),
          ],
          showUnselectedLabels: true,
          selectedItemColor: ColorManger.greenColor,
          unselectedItemColor: Color(0xff8789A3),
          selectedLabelStyle: TextStyles.bottomNavTextSelceted,
          unselectedLabelStyle: TextStyles.bottomNavTextUnSelceted,
        ),
      ),
    ),);
  }
}