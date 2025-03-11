import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:depi1/resources/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen1> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
precacheImage(AssetImage(ImageManger.animationSplash),context);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSplashScreen(
        splash: Center(
          child: Column(
            children: [

              Lottie.asset(
                ImageManger.animationSplash,

              height: 250,width: 250),
              const SizedBox(
                height: 16,
              ),
              const Text(
                textAlign: TextAlign.center,
                "صلاتك اولا ",
                style: TextStyle(
                    fontFamily: 'Amiri', fontSize: 39, color: Color(0xff0C6E52),fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
        nextScreen: OnBoardingScreen(),
        duration: 3000,
        splashIconSize: 500,
        // Duration of the splash screen
      ),
    );
  }
}


