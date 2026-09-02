import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:salaty/core/error/failures.dart';
import 'package:salaty/features/statistics/domain/entities/prayer_statistics_entity.dart';
import 'package:salaty/features/statistics/domain/entities/weekly_achievement_entity.dart';
import 'package:salaty/features/statistics/domain/usecases/get_statistics_usecase.dart';
import 'package:salaty/features/statistics/domain/usecases/watch_statistics_changes_usecase.dart';
import 'package:salaty/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:salaty/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetStatistics extends Mock implements GetStatisticsUseCase {}

class _MockWatchChanges extends Mock implements WatchStatisticsChangesUseCase {}

void main() {
  late _MockGetStatistics getStatistics;
  late _MockWatchChanges watchChanges;
  late StreamController<void> changes;

  const stats = PrayerStatisticsEntity(
    weekly: WeeklyAchievementEntity(performed: 12, target: 35),
    breakdowns: [],
    totalRecorded: 12,
  );

  StatisticsCubit buildCubit() => StatisticsCubit(
        getStatistics: getStatistics,
        watchChanges: watchChanges,
      );

  setUp(() {
    getStatistics = _MockGetStatistics();
    watchChanges = _MockWatchChanges();
    changes = StreamController<void>.broadcast();
    when(watchChanges.call).thenAnswer((_) => changes.stream);
  });

  tearDown(() => changes.close());

  group('start', () {
    blocTest<StatisticsCubit, StatisticsState>(
      'emits loading then loaded',
      setUp: () => when(getStatistics.call)
          .thenAnswer((_) async => const Right(stats)),
      build: buildCubit,
      act: (cubit) => cubit.start(),
      expect: () => [
        const StatisticsLoading(),
        const StatisticsLoaded(stats),
      ],
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'surfaces a failure message',
      setUp: () => when(getStatistics.call)
          .thenAnswer((_) async => const Left(CacheFailure('storage gone'))),
      build: buildCubit,
      act: (cubit) => cubit.start(),
      expect: () => [
        const StatisticsLoading(),
        const StatisticsError('storage gone'),
      ],
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'refreshes when a prayer status is recorded',
      setUp: () => when(getStatistics.call)
          .thenAnswer((_) async => const Right(stats)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        changes.add(null);
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) => verify(getStatistics.call).called(2),
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'does not blank the screen while refreshing',
      // A refresh must not drop back to a spinner over data already on screen.
      setUp: () => when(getStatistics.call)
          .thenAnswer((_) async => const Right(stats)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        await cubit.loadStatistics();
      },
      expect: () => [
        const StatisticsLoading(),
        const StatisticsLoaded(stats),
      ],
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'subscribes to changes only once across repeated starts',
      setUp: () => when(getStatistics.call)
          .thenAnswer((_) async => const Right(stats)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.start();
        await cubit.start();
      },
      verify: (_) => verify(watchChanges.call).called(1),
    );
  });

  test('close stops refreshing on later changes', () async {
    when(getStatistics.call).thenAnswer((_) async => const Right(stats));

    final cubit = buildCubit();
    await cubit.start();
    await cubit.close();

    changes.add(null);
    await Future<void>.delayed(Duration.zero);

    verify(getStatistics.call).called(1);
  });
}
