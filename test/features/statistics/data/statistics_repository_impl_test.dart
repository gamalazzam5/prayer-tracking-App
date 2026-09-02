import 'dart:async';

import 'package:salaty/core/error/exceptions.dart';
import 'package:salaty/core/error/failures.dart';
import 'package:salaty/core/storage/prayer_local_storage.dart';
import 'package:salaty/core/storage/prayer_record.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_name.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_status.dart';
import 'package:salaty/features/statistics/data/repos/statistics_repository_impl.dart';
import 'package:salaty/features/statistics/domain/entities/prayer_statistics_entity.dart';
import 'package:salaty/features/statistics/domain/entities/status_breakdown_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements PrayerLocalStorage {}

void main() {
  late _MockStorage storage;
  late StatisticsRepositoryImpl repository;

  final now = DateTime(2026, 9, 7, 12);

  PrayerRecord rec(String dateKey, PrayerName name, PrayerStatus? status) =>
      PrayerRecord(
        dateKey: dateKey,
        prayerId: name.id,
        timeIso: '${dateKey}T04:30:00.000',
        statusId: status?.id,
      );

  StatusBreakdownEntity breakdownFor(
    PrayerStatisticsEntity stats,
    PrayerStatus status,
  ) =>
      stats.breakdowns.firstWhere((b) => b.status == status);

  setUp(() {
    storage = _MockStorage();
    repository = StatisticsRepositoryImpl(storage: storage, now: () => now);
    when(() => storage.getInRange(any(), any())).thenReturn(<PrayerRecord>[]);
    when(() => storage.getAll()).thenReturn(<PrayerRecord>[]);
  });

  group('getStatistics', () {
    test('reports zeroes for an empty store without dividing by zero', () async {
      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.totalRecorded, 0);
      expect(stats.weekly.performed, 0);
      expect(stats.weekly.progress, 0);
      expect(stats.breakdowns, hasLength(PrayerStatus.values.length));
      for (final breakdown in stats.breakdowns) {
        expect(breakdown.count, 0);
        expect(breakdown.shareOfAll, 0);
        expect(breakdown.perPrayerShare.values, everyElement(0.0));
      }
    });

    test('ignores unrecorded prayers when counting', () async {
      // Seeded future days carry a null status; they must not count as data.
      when(() => storage.getAll()).thenReturn([
        rec('2026-09-01', PrayerName.fajr, PrayerStatus.congregation),
        rec('2026-09-01', PrayerName.dhuhr, null),
        rec('2026-09-08', PrayerName.fajr, null),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.totalRecorded, 1);
      expect(breakdownFor(stats, PrayerStatus.congregation).count, 1);
      expect(breakdownFor(stats, PrayerStatus.congregation).shareOfAll, 1.0);
    });

    test('computes each status share of all recorded prayers', () async {
      when(() => storage.getAll()).thenReturn([
        rec('2026-09-01', PrayerName.fajr, PrayerStatus.congregation),
        rec('2026-09-01', PrayerName.dhuhr, PrayerStatus.congregation),
        rec('2026-09-01', PrayerName.asr, PrayerStatus.late),
        rec('2026-09-01', PrayerName.maghrib, PrayerStatus.missed),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.totalRecorded, 4);
      expect(breakdownFor(stats, PrayerStatus.congregation).shareOfAll, 0.5);
      expect(breakdownFor(stats, PrayerStatus.late).shareOfAll, 0.25);
      expect(breakdownFor(stats, PrayerStatus.missed).shareOfAll, 0.25);
      expect(breakdownFor(stats, PrayerStatus.alone).shareOfAll, 0);
    });

    test('breaks a status down per prayer', () async {
      when(() => storage.getAll()).thenReturn([
        rec('2026-09-01', PrayerName.fajr, PrayerStatus.missed),
        rec('2026-09-02', PrayerName.fajr, PrayerStatus.missed),
        rec('2026-09-03', PrayerName.fajr, PrayerStatus.missed),
        rec('2026-09-01', PrayerName.isha, PrayerStatus.missed),
      ]);

      final missed = breakdownFor(
        (await repository.getStatistics()).getOrElse(() => throw 'left'),
        PrayerStatus.missed,
      );

      expect(missed.count, 4);
      expect(missed.perPrayerShare[PrayerName.fajr], 0.75);
      expect(missed.perPrayerShare[PrayerName.isha], 0.25);
      expect(missed.perPrayerShare[PrayerName.asr], 0);
    });

    test('shares of one status always sum to one', () async {
      when(() => storage.getAll()).thenReturn([
        for (final name in PrayerName.values)
          rec('2026-09-01', name, PrayerStatus.alone),
      ]);

      final alone = breakdownFor(
        (await repository.getStatistics()).getOrElse(() => throw 'left'),
        PrayerStatus.alone,
      );

      final total = alone.perPrayerShare.values
          .fold<double>(0, (sum, value) => sum + value);
      expect(total, closeTo(1.0, 1e-9));
    });

    test('skips rows referencing an unknown prayer or status', () async {
      when(() => storage.getAll()).thenReturn([
        rec('2026-09-01', PrayerName.fajr, PrayerStatus.late),
        const PrayerRecord(
          dateKey: '2026-09-01',
          prayerId: 'tahajjud',
          timeIso: '2026-09-01T02:00:00.000',
          statusId: 'late',
        ),
        const PrayerRecord(
          dateKey: '2026-09-01',
          prayerId: 'dhuhr',
          timeIso: '2026-09-01T12:00:00.000',
          statusId: 'skipped_somehow',
        ),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.totalRecorded, 1);
    });

    test('maps a storage error to a CacheFailure', () async {
      when(() => storage.getAll()).thenThrow(const CacheException('gone'));

      final result = await repository.getStatistics();

      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('right'));
    });
  });

  group('weekly achievement', () {
    test('targets seven days of five prayers', () async {
      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');
      expect(stats.weekly.target, 35);
    });

    test('queries the seven-day window ending today, inclusive', () async {
      await repository.getStatistics();
      verify(() => storage.getInRange('2026-09-01', '2026-09-07')).called(1);
    });

    test('counts only prayers that were actually performed', () async {
      when(() => storage.getInRange(any(), any())).thenReturn([
        rec('2026-09-05', PrayerName.fajr, PrayerStatus.congregation),
        rec('2026-09-05', PrayerName.dhuhr, PrayerStatus.late),
        rec('2026-09-05', PrayerName.asr, PrayerStatus.alone),
        // Neither of these counts towards the goal.
        rec('2026-09-05', PrayerName.maghrib, PrayerStatus.missed),
        rec('2026-09-05', PrayerName.isha, null),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.weekly.performed, 3);
      expect(stats.weekly.progress, closeTo(3 / 35, 1e-9));
      expect(stats.weekly.isComplete, isFalse);
    });

    test('reports completion when the whole week is prayed', () async {
      when(() => storage.getInRange(any(), any())).thenReturn([
        for (var day = 1; day <= 7; day++)
          for (final name in PrayerName.values)
            rec('2026-09-0$day', name, PrayerStatus.congregation),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.weekly.performed, 35);
      expect(stats.weekly.progress, 1.0);
      expect(stats.weekly.isComplete, isTrue);
    });

    test('clamps progress at 100% if the data ever exceeds the target',
        () async {
      when(() => storage.getInRange(any(), any())).thenReturn([
        for (var i = 0; i < 40; i++)
          rec('2026-09-05', PrayerName.fajr, PrayerStatus.congregation),
      ]);

      final stats =
          (await repository.getStatistics()).getOrElse(() => throw 'left');

      expect(stats.weekly.progress, 1.0);
    });
  });

  group('watchChanges', () {
    test('forwards the storage status-change stream', () async {
      final controller = StreamController<void>.broadcast();
      when(() => storage.onStatusChanged).thenAnswer((_) => controller.stream);

      final emissions = <void>[];
      final subscription = repository.watchChanges().listen(emissions.add);

      controller.add(null);
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, hasLength(2));
      await subscription.cancel();
      await controller.close();
    });
  });
}
