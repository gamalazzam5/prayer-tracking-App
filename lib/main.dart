import 'package:depi1/services/prayer_service.dart';
import 'package:depi1/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // للتحكم في توجيه الشاشة

import 'controller/calender_controller.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  Get.put(DateController());


  await PrayerService.initializePrayerTimes();

  runApp(const Salaty());
}

class Salaty extends StatelessWidget {
  const Salaty({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenUtilInit(
      designSize: Size(402, 880),
      minTextAdapt: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}