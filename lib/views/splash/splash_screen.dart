import 'package:depi1/main.dart';
import 'package:depi1/resources/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnBoardingScreen(),),);
    });
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
              child: SvgPicture.asset(
                ImageManger.splash,
                height: 187.h,
                width: 250.w,
              ),
            ),
             SizedBox(
              height: 16.h,
            ),
             Text(
              textAlign: TextAlign.center,
              "صلاتك اولا ",
              style: TextStyle(
                  fontFamily: 'Amiri', fontSize: 39.sp, color: Color(0xff0C6E52),fontWeight: FontWeight.w400),
            )
          ],
        ),),
    );
  }
}

