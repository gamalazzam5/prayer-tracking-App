import 'package:depi1/controller/home_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../resources/colors.dart';
import '../resources/text_style.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewController>(
      init: HomeViewController(),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xffFAF8F2),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/pattern.png'),
              fit: BoxFit.cover,
              opacity: .07,
            ),
          ),
          child: IndexedStack(
            index: controller.myIndex,
            children: controller.screens,
          ),
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
          child: Container(
            height: 87.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.r),
                topRight: Radius.circular(25.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  spreadRadius: 2.r,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              onTap: controller.onItemTapped,
              currentIndex: controller.myIndex,
              items: controller.buildNavItems(),
              showUnselectedLabels: true,
              selectedItemColor: ColorManger.greenColor,
              unselectedItemColor: const Color(0xff8789A3),
              selectedLabelStyle: TextStyles.bottomNavTextUnSelceted,
              unselectedLabelStyle: TextStyles.bottomNavTextUnSelceted,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }
}