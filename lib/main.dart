import 'package:depi1/views/home_view.dart';
import 'package:depi1/views/home/home.dart';
import 'package:depi1/views/splash/test1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'views/splash/splash_screen.dart';

void main() => runApp(SalatyAwalan());

class SalatyAwalan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(402, 880),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
