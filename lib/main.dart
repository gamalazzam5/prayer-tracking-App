import 'package:depi1/services/prayer_service.dart';
import 'package:depi1/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controller/calender_controller.dart';

void main() async {
  // التأكد من تهيئة كل شيء
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة DateController
  Get.put(DateController());

  // تهيئة بيانات الصلاة لآخر 30 يومًا وأول 30 يومًا في المستقبل
  await PrayerService.initializePrayerTimes();

runApp(Salaty());
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
