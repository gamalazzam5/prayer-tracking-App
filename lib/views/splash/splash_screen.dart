import 'package:depi1/resources/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_view.dart';
import '../onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    Future.delayed(const Duration(seconds: 3), () {
      if (isFirstTime) {
        prefs.setBool('isFirstTime', false);
        Get.off(const OnBoardingScreen());
      } else {
        Get.off(HomeView());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(ImageManger.splash), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 238),
              child: Image.asset(
                ImageManger.splash,
                height: 187.h,
                width: 250.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              textAlign: TextAlign.center,
              "صلاتك اولا ",
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 39.sp,
                color: const Color(0xff0C6E52),
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}
