import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:salaty/core/error/failures.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_entity.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_name.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_status.dart';
import 'package:salaty/features/prayer/domain/usecases/get_prayers_for_date_usecase.dart';
import 'package:salaty/features/prayer/domain/usecases/update_prayer_status_usecase.dart';
import 'package:salaty/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:salaty/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPrayers extends Mock implements GetPrayersForDateUseCase {}

class _MockUpdateStatus extends Mock implements UpdatePrayerStatusUseCase {}

void main() {
  late _MockGetPrayers getPrayers;
  late _MockUpdateStatus updateStatus;

  final date = DateTime(2026, 9, 1);

  final prayers = [
    PrayerEntity(name: PrayerName.fajr, time: DateTime(2026, 9, 1, 4, 30)),
    PrayerEntity(name: PrayerName.dhuhr, time: DateTime(2026, 9, 1, 12)),
  ];

  PrayerCubit buildCubit() => PrayerCubit(
        getPrayersForDate: getPrayers,
        updatePrayerStatus: updateStatus,
      );

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(
      PrayerEntity(name: PrayerName.fajr, time: DateTime(2026)),
    );
  });

  setUp(() {
    getPrayers = _MockGetPrayers();
    updateStatus = _MockUpdateStatus();
  });

  group('loadPrayers', () {
    blocTest<PrayerCubit, PrayerState>(
      'emits loading then loaded on success',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) => cubit.loadPrayers(date),
      expect: () => [
        const PrayerLoading(),
        PrayerLoaded(prayers: prayers, date: date),
      ],
    );

    blocTest<PrayerCubit, PrayerState>(
      'emits the failure message on error',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => const Left(PrayerCalculationFailure())),
      build: buildCubit,
      act: (cubit) => cubit.loadPrayers(date),
      expect: () => [
        const PrayerLoading(),
        const PrayerError('تعذر حساب مواقيت الصلاة'),
      ],
    );

    blocTest<PrayerCubit, PrayerState>(
      'reloads for a newly selected date',
      setUp: () => when(() => getPrayers(any()))
          .thenAnswer((_) async => Right(prayers)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadPrayers(date);
        await cubit.loadPrayers(date.add(const Duration(days: 1)));
      },
      verify: (_) => verify(() => getPrayers(any())).called(2),
    );
  });

  group('recordStatus', () {
    final updated = PrayerEntity(
      name: PrayerName.fajr,
      time: DateTime(2026, 9, 1, 4, 30),
      status: PrayerStatus.congregation,
    );

    blocTest<PrayerCubit, PrayerState>(
      'patches the recorded prayer in place, leaving the others untouched',
      setUp: () {
        when(() => getPrayers(any())).thenAnswer((_) async => Right(prayers));
        when(() => updateStatus(
              date: any(named: 'date'),
              prayer: any(named: 'prayer'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => Right(updated));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadPrayers(date);
        await cubit.recordStatus(
          prayer: prayers.first,
          status: PrayerStatus.congregation,
        );
      },
      skip: 2,
      expect: () => [
        PrayerLoaded(prayers: [updated, prayers[1]], date: date),
      ],
    );

    blocTest<PrayerCubit, PrayerState>(
      'does nothing when no day is loaded yet',
      build: buildCubit,
      act: (cubit) => cubit.recordStatus(
        prayer: prayers.first,
        status: PrayerStatus.late,
      ),
      expect: () => <PrayerState>[],
      verify: (_) => verifyNever(() => updateStatus(
            date: any(named: 'date'),
            prayer: any(named: 'prayer'),
            status: any(named: 'status'),
          )),
    );

    blocTest<PrayerCubit, PrayerState>(
      'surfaces a write failure',
      setUp: () {
        when(() => getPrayers(any())).thenAnswer((_) async => Right(prayers));
        when(() => updateStatus(
              date: any(named: 'date'),
              prayer: any(named: 'prayer'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Left(CacheFailure('write failed')));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadPrayers(date);
        await cubit.recordStatus(
          prayer: prayers.first,
          status: PrayerStatus.late,
        );
      },
      skip: 2,
      expect: () => [const PrayerError('write failed')],
    );
  });
}
