import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../onboarding/domain/usecases/has_seen_onboarding_usecase.dart';
import '../../../prayer/domain/usecases/seed_prayer_times_usecase.dart';
import 'splash_state.dart';

/// Runs start-up work behind the splash screen, then picks the first route.
class SplashCubit extends Cubit<SplashState> {
  final HasSeenOnboardingUseCase _hasSeenOnboarding;
  final SeedPrayerTimesUseCase _seedPrayerTimes;
  final Duration _minimumDuration;

  SplashCubit({
    required HasSeenOnboardingUseCase hasSeenOnboarding,
    required SeedPrayerTimesUseCase seedPrayerTimes,
    Duration minimumDuration = AppConstants.splashDuration,
  })  : _hasSeenOnboarding = hasSeenOnboarding,
        _seedPrayerTimes = seedPrayerTimes,
        _minimumDuration = minimumDuration,
        super(const SplashLoading());

  Future<void> bootstrap() async {
    // Seeding is started but deliberately not awaited. It can block on the
    // OS location-permission dialog for as long as the user takes to answer,
    // and the splash must not sit there waiting; whatever it manages to cache
    // simply speeds up the first prayer screen. Failures are swallowed for the
    // same reason — the prayer screen surfaces the error and offers a retry,
    // rather than the white screen the previous start-up produced when
    // location threw before `runApp`.
    unawaited(_seedPrayerTimes());

    final hold = Future<void>.delayed(_minimumDuration);
    final hasSeen = (await _hasSeenOnboarding()).getOrElse(() => false);

    await hold;
    if (isClosed) return;

    emit(SplashReady(
      hasSeen ? SplashDestination.home : SplashDestination.onboarding,
    ));
  }
}
