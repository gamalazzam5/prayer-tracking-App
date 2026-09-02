import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:depi1/core/error/failures.dart';
import 'package:depi1/features/onboarding/domain/usecases/has_seen_onboarding_usecase.dart';
import 'package:depi1/features/prayer/domain/usecases/seed_prayer_times_usecase.dart';
import 'package:depi1/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:depi1/features/splash/presentation/cubit/splash_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHasSeenOnboarding extends Mock implements HasSeenOnboardingUseCase {}

class _MockSeedPrayerTimes extends Mock implements SeedPrayerTimesUseCase {}

void main() {
  late _MockHasSeenOnboarding hasSeenOnboarding;
  late _MockSeedPrayerTimes seedPrayerTimes;

  SplashCubit buildCubit() => SplashCubit(
        hasSeenOnboarding: hasSeenOnboarding,
        seedPrayerTimes: seedPrayerTimes,
        minimumDuration: Duration.zero,
      );

  setUp(() {
    hasSeenOnboarding = _MockHasSeenOnboarding();
    seedPrayerTimes = _MockSeedPrayerTimes();
    when(seedPrayerTimes.call).thenAnswer((_) async => const Right(unit));
  });

  group('bootstrap', () {
    blocTest<SplashCubit, SplashState>(
      'routes to onboarding on a first run',
      setUp: () =>
          when(hasSeenOnboarding.call).thenAnswer((_) async => const Right(false)),
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const SplashReady(SplashDestination.onboarding)],
    );

    blocTest<SplashCubit, SplashState>(
      'routes home once onboarding has been seen',
      setUp: () =>
          when(hasSeenOnboarding.call).thenAnswer((_) async => const Right(true)),
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const SplashReady(SplashDestination.home)],
    );

    blocTest<SplashCubit, SplashState>(
      'shows onboarding rather than skipping it when the flag cannot be read',
      setUp: () => when(hasSeenOnboarding.call)
          .thenAnswer((_) async => const Left(CacheFailure())),
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const SplashReady(SplashDestination.onboarding)],
    );

    blocTest<SplashCubit, SplashState>(
      'still starts the app when prayer-time seeding fails',
      // Regression: the old start-up awaited seeding before `runApp`, so a
      // denied location permission left the user on a white screen.
      setUp: () {
        when(hasSeenOnboarding.call)
            .thenAnswer((_) async => const Right(true));
        when(seedPrayerTimes.call).thenAnswer(
          (_) async => const Left(LocationFailure.permissionDenied),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const SplashReady(SplashDestination.home)],
    );

    test('does not wait for seeding to finish before routing', () async {
      // Seeding can block on the OS permission dialog indefinitely; the splash
      // must route anyway.
      final blocked = Completer<Either<Failure, Unit>>();
      when(seedPrayerTimes.call).thenAnswer((_) => blocked.future);
      when(hasSeenOnboarding.call).thenAnswer((_) async => const Right(true));

      final cubit = buildCubit();
      await cubit.bootstrap();

      expect(cubit.state, const SplashReady(SplashDestination.home));
      expect(blocked.isCompleted, isFalse);

      blocked.complete(const Right(unit));
      await cubit.close();
    });

    test('starts seeding exactly once', () async {
      when(hasSeenOnboarding.call).thenAnswer((_) async => const Right(true));

      final cubit = buildCubit();
      await cubit.bootstrap();

      verify(seedPrayerTimes.call).called(1);
      await cubit.close();
    });
  });
}
