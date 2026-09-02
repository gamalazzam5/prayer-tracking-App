import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_page_entity.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Created here, not in `build`, and disposed below.
  late final PageController _pageController = PageController();

  static const List<OnboardingPageEntity> _pages = [
    OnboardingPageEntity(
      imageAsset: AppAssets.onboarding1,
      title: 'القبلة دائمًا معك',
      subtitle:
          'أينما كنت، لن يكون العثور على اتجاه القبلة أمرًا صعبًا بعد الآن! '
          'يوفر لك التطبيق بوصلة مدمجة بتصميم دقيق وسهل الاستخدام، لتتمكن من '
          'أداء صلاتك بكل راحة وثقة في أي مكان في العالم',
    ),
    OnboardingPageEntity(
      imageAsset: AppAssets.onboarding2,
      title: 'صلاتك في يدك، لا تفوّت ركعة!',
      subtitle:
          'هل تصلي في المسجد أم بمفردك؟ هل أديت الصلاة في وقتها أم تأخرت؟ '
          'الآن يمكنك تسجيل صلواتك بسهولة ومعرفة مدى التزامك بالصلاة على مدار '
          'الأيام، مما يساعدك على تحسين أدائك الروحي والاستمرار في التطور',
    ),
    OnboardingPageEntity(
      imageAsset: AppAssets.onboarding3,
      title: 'راقب تقدمك والتزم أكثر!',
      subtitle:
          'تحليل صلواتك يمنحك رؤية واضحة عن مدى التزامك. يتيح لك التطبيق '
          'استعراض إحصائيات يومية وأسبوعية وشهرية حول صلواتك، مما يساعدك على '
          'تتبع تقدمك وتحقيق أهدافك الروحية بسهولة',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final page in _pages) {
      precacheImage(AssetImage(page.imageAsset), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          !previous.isCompleted && current.isCompleted,
      listener: (context, _) => Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged:
                      context.read<OnboardingCubit>().onPageChanged,
                  itemBuilder: (context, index) =>
                      OnboardingPageContent(page: _pages[index]),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h, left: 20.w, right: 20.w),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        buildWhen: (previous, current) =>
            previous.pageIndex != current.pageIndex,
        builder: (context, state) {
          final isLastPage = state.pageIndex == _pages.length - 1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingDots(
                    count: _pages.length,
                    activeIndex: state.pageIndex,
                    activeColor: AppColors.green,
                    inactiveColor: AppColors.brown,
                  ),
                  TextButton(
                    onPressed: cubit.complete,
                    child: Text('تخطي', style: AppTextStyles.skip),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (isLastPage) {
                    cubit.complete();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLastPage ? Icons.check : Icons.arrow_forward_ios,
                    color: AppColors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
