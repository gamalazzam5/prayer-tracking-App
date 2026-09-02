import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:salaty/core/error/failures.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_entity.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_name.dart';
import 'package:salaty/features/prayer/domain/usecases/get_prayers_for_date_usecase.dart';
import 'package:salaty/features/prayer/domain/usecases/resolve_next_prayer_usecase.dart';
import 'package:salaty/features/prayer/presentation/cubit/next_prayer_cubit.dart';
import 'package:salaty/features/prayer/presentation/cubit/next_prayer_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPrayers extends Mock implements GetPrayersForDateUseCase {}

void main() {
  late _MockGetPrayers getPrayers;

  /// Pinned clock; nothing here depends on the wall clock or a real timer.
  var now = DateTime(2026, 9, 1, 10);

  final prayers = [
    PrayerEntity(name: PrayerName.fajr, time: DateTime(2026, 9, 1, 4, 30)),
    PrayerEntity(name: PrayerName.dhuhr, time: DateTime(2026, 9, 1, 12)),
    PrayerEntity(name: PrayerName.isha, time: DateTime(2026, 9, 1, 20)),
  ];

  NextPrayerCubit buildCubit() => NextPrayerCubit(
        getPrayersForDate: getPrayers,
        resolveNextPrayer: const ResolveNextPrayerUseCase(),
        now: () => now,
        // Long enough that the periodic timer never fires during a test; ticks
        // are driven explicitly instead.
        tickInterval: const Duration(days: 1),
      );

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    getPrayers = _MockGetPrayers();
    now = DateTime(2026, 9, 1, 10);
  });

  group('start', () {
    blocTest<NextPrayerCubit, NextPrayerState>(
      'emits the next prayer with its countdown and Hijri date',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) => cubit.start(),
      verify: (cubit) {
        final state = cubit.state as NextPrayerReady;
        expect(state.nextPrayer.prayer.name, PrayerName.dhuhr);
        expect(state.nextPrayer.remaining, const Duration(hours: 2));
        expect(state.hijriDate, contains('هـ'));
      },
    );

    blocTest<NextPrayerCubit, NextPrayerState>(
      'stays unavailable when prayers cannot be loaded, without throwing',
      // Regression: the old controller indexed into an empty list on the very
      // first timer tick and crashed with a RangeError.
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => const Left(PrayerCalculationFailure())),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        cubit.tick();
        cubit.tick();
      },
      verify: (cubit) => expect(cubit.state, isA<NextPrayerUnavailable>()),
    );

    blocTest<NextPrayerCubit, NextPrayerState>(
      'requests today and tomorrow, not arbitrary timestamps',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) => cubit.start(),
      verify: (_) {
        verify(() => getPrayers(DateTime(2026, 9, 1))).called(1);
        // Tomorrow is needed so the post-Isha countdown targets the real Fajr.
        verify(() => getPrayers(DateTime(2026, 9, 2))).called(1);
      },
    );
  });

  group('tick', () {
    blocTest<NextPrayerCubit, NextPrayerState>(
      'counts down as time passes',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        now = DateTime(2026, 9, 1, 11, 30);
        cubit.tick();
      },
      verify: (cubit) {
        final state = cubit.state as NextPrayerReady;
        expect(state.nextPrayer.remaining, const Duration(minutes: 30));
      },
    );

    blocTest<NextPrayerCubit, NextPrayerState>(
      'advances to the following prayer once one is due',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        now = DateTime(2026, 9, 1, 12, 1);
        cubit.tick();
      },
      verify: (cubit) {
        final state = cubit.state as NextPrayerReady;
        expect(state.nextPrayer.prayer.name, PrayerName.isha);
      },
    );

    blocTest<NextPrayerCubit, NextPrayerState>(
      'reloads the day after midnight rolls over',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        now = DateTime(2026, 9, 2, 1);
        cubit.tick();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        // Sept 3 is only ever requested as the new "tomorrow", which proves
        // the rollover reload actually ran.
        verify(() => getPrayers(DateTime(2026, 9, 3))).called(1);
      },
    );

    test('a rollover reload is not restarted by every subsequent tick',
        () async {
      // Regression: `_loadedDay` is only updated once the async load returns,
      // so without a re-entrancy guard every tick during the load kicked off
      // another one.
      final gate = Completer<Either<Failure, List<PrayerEntity>>>();
      var blockNextLoad = false;
      var calls = 0;

      when(() => getPrayers(any())).thenAnswer((_) {
        calls++;
        // Let start() complete normally; only stall the rollover reload.
        return blockNextLoad
            ? gate.future
            : Future.value(Right<Failure, List<PrayerEntity>>(prayers));
      });

      final cubit = buildCubit();
      await cubit.start();

      final callsAfterStart = calls;
      blockNextLoad = true;
      now = DateTime(2026, 9, 2, 1);

      for (var i = 0; i < 5; i++) {
        cubit.tick();
        await Future<void>.delayed(Duration.zero);
      }

      // Exactly one reload was started, no matter how many ticks fired.
      expect(calls, callsAfterStart + 1);

      gate.complete(Right(prayers));
      await cubit.close();
    });
  });

  test('close cancels the ticker so no state is emitted afterwards', () async {
    when(() => getPrayers(any())).thenAnswer((_) async => Right(prayers));

    final cubit = NextPrayerCubit(
      getPrayersForDate: getPrayers,
      resolveNextPrayer: const ResolveNextPrayerUseCase(),
      now: () => now,
      tickInterval: const Duration(milliseconds: 1),
    );

    await cubit.start();
    await cubit.close();

    // Ticking a closed cubit must be a no-op rather than a state error.
    expect(cubit.tick, returnsNormally);
  });
}
