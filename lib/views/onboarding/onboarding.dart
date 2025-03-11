import 'package:depi1/resources/colors.dart';
import 'package:depi1/resources/image_manager.dart';
import 'package:depi1/views/home_view.dart';
import 'package:depi1/views/onboarding/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../resources/text_style.dart';
import '../home/home.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();
  final List<OnboardingData> _onboarding = [
    OnboardingData(
        imageUrl: ImageManger.image1,
        title: "القبلة دائمًا معك",
        subTitle:
        "أينما كنت، لن يكون العثور على اتجاه القبلة أمرًا صعبًا بعد الآن! يوفر لك التطبيق بوصلة مدمجة بتصميم دقيق وسهل الاستخدام، لتتمكن من أداء صلاتك بكل راحة وثقة في أي مكان في العالم"),
    OnboardingData(
        imageUrl: ImageManger.image2,
        title: "صلاتك في يدك، لا تفوّت ركعة!",
        subTitle:
        "هل تصلي في المسجد أم بمفردك؟ هل أديت الصلاة في وقتها أم تأخرت؟ الآن يمكنك تسجيل صلواتك بسهولة ومعرفة مدى التزامك بالصلاة على مدار الأيام، مما يساعدك على تحسين أدائك الروحي والاستمرار في  التطور"),
    OnboardingData(
        imageUrl: ImageManger.image3,
        title: "راقب تقدمك والتزم أكثر!",
        subTitle:
        "تحليل صلواتك يمنحك رؤية واضحة عن مدى التزامك. يتيح لك التطبيق استعراض إحصائيات يومية وأسبوعية وشهرية حول صلواتك، مما يساعدك على تتبع تقدمك وتحقيق أهدافك الروحية بسهولة")
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(AssetImage(ImageManger.image1), context);
    precacheImage(AssetImage(ImageManger.image2), context);
    precacheImage(AssetImage(ImageManger.image3), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildPageView(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _onboarding.length,
        onPageChanged: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              Image.asset(
                _onboarding[index].imageUrl,
                width:1.sw,
                height: 490.h,
                fit: BoxFit.cover,
              ),
               SizedBox(height: 35.h),
              Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(right: 20.0.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _onboarding[index].title,
                        textDirection: TextDirection.rtl,
                        style: TextStyles.titleBoarding,
                      ),
                    ),
                  ),
                   SizedBox(
                    height: 24.h,
                  ),
                  Padding(
                    padding:  EdgeInsets.only(right: 20.0.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _onboarding[index].subTitle,
                        style: TextStyles.subtitleBoarding,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(bottom: 40.h, right: 20.w, left: 20.w),
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(
                    _onboarding.length,
                        (index) => Padding(
                      padding:  EdgeInsets.all(5.0.w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: _pageIndex == index ? 30.w : 14.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.5.r),
                          color: _pageIndex == index
                              ? ColorManger.greenColor
                              : ColorManger.brawenColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 17.h,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView()),
                    );
                  },
                  child: Text(
                    "تخطي",
                    style: TextStyles.skipStyle,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  if (_pageIndex == _onboarding.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView()),
                    );
                  } else {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  }
                },
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: ColorManger.greenColor,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child:  Icon(
                    Icons.arrow_forward_ios,
                    color: ColorManger.primaryColor,
                    size: 24.sp,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
