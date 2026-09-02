import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/home_nav_cubit.dart';

/// Bottom navigation bar for the three main tabs.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  static const Map<HomeTab, ({String icon, String label})> _items = {
    HomeTab.prayers: (icon: AppAssets.navHome, label: 'الرئيسية'),
    HomeTab.qibla: (icon: AppAssets.navQibla, label: 'القِبْلَة'),
    HomeTab.statistics: (icon: AppAssets.navStatistics, label: 'الإحصائيات'),
  };

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<HomeNavCubit>().state;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              spreadRadius: 2.r,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab.index,
          onTap: context.read<HomeNavCubit>().selectIndex,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.navUnselected,
          selectedLabelStyle: AppTextStyles.navLabel,
          unselectedLabelStyle: AppTextStyles.navLabel,
          items: [
            for (final tab in HomeTab.values)
              BottomNavigationBarItem(
                label: _items[tab]!.label,
                icon: Image.asset(
                  _items[tab]!.icon,
                  height: 24.h,
                  width: 24.w,
                  color: tab == currentTab
                      ? AppColors.green
                      : AppColors.navUnselected,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
