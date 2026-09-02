import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/resources/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer/presentation/cubit/next_prayer_cubit.dart';
import '../../../prayer/presentation/cubit/prayer_cubit.dart';
import '../../../prayer/presentation/cubit/selected_date_cubit.dart';
import '../../../prayer/presentation/screens/prayer_screen.dart';
import '../../../qibla/presentation/cubit/qibla_cubit.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
import '../../../statistics/presentation/cubit/statistics_cubit.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../cubit/home_nav_cubit.dart';
import '../widgets/home_bottom_nav.dart';

/// Tab shell hosting the three main screens.
///
/// Each tab gets its own cubit, provided here so a tab's state survives being
/// switched away from and back to.
class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeNavCubit>()),
        BlocProvider(create: (_) => sl<SelectedDateCubit>()),
        BlocProvider(
          create: (context) => sl<PrayerCubit>()
            ..loadPrayers(context.read<SelectedDateCubit>().state.date),
        ),
        BlocProvider(create: (_) => sl<NextPrayerCubit>()..start()),
        BlocProvider(create: (_) => sl<QiblaCubit>()),
        BlocProvider(create: (_) => sl<StatisticsCubit>()..start()),
      ],
      child: const _HomeShellView(),
    );
  }
}

class _HomeShellView extends StatelessWidget {
  const _HomeShellView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.pattern),
            fit: BoxFit.cover,
            opacity: 0.07,
          ),
        ),
        // IndexedStack keeps each tab alive, so switching back does not
        // re-run its load.
        child: BlocListener<HomeNavCubit, HomeTab>(
          // The compass is only subscribed while its tab is on screen. Starting
          // it with the shell would hold the magnetometer open — and drain the
          // battery — the whole time the user is on another tab.
          listener: (context, tab) {
            final qibla = context.read<QiblaCubit>();
            if (tab == HomeTab.qibla) {
              qibla.start();
            } else {
              qibla.stop();
            }
          },
          child: BlocBuilder<HomeNavCubit, HomeTab>(
            builder: (context, tab) => IndexedStack(
              index: tab.index,
              children: const [
                PrayerScreen(),
                QiblaScreen(),
                StatisticsScreen(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}
