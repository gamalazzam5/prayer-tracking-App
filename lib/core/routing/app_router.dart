import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../di/injection_container.dart';
import 'app_routes.dart';

/// Builds routes and provides each screen's cubit at the route boundary.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.onboarding => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<OnboardingCubit>(),
            child: const OnboardingScreen(),
          ),
        ),
      AppRoutes.home => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeShellScreen(),
        ),
      _ => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<SplashCubit>()..bootstrap(),
            child: const SplashScreen(),
          ),
        ),
    };
  }
}
