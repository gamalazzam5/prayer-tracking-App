import 'dart:io';

import 'package:salaty/core/error/exceptions.dart';
import 'package:salaty/core/storage/hive_prayer_local_storage.dart';
import 'package:salaty/core/storage/prayer_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;
  late HivePrayerLocalStorage storage;

  PrayerRecord record(
    String dateKey,
    String prayerId,
    String time, {
    String? statusId,
  }) =>
      PrayerRecord(
        dateKey: dateKey,
        prayerId: prayerId,
        timeIso: '${dateKey}T$time',
        statusId: statusId,
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('prayer_storage_test');
    Hive.init(tempDir.path);
    storage = HivePrayerLocalStorage(hive: Hive, boxName: 'prayers_test');
    await storage.init();
  });

  tearDown(() async {
    await storage.close();
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('init', () {
    test('is idempotent', () async {
      await storage.init();
      await storage.init();
      expect(storage.getAll(), isEmpty);
    });

    test('reading before init throws a CacheException', () async {
      final fresh = HivePrayerLocalStorage(hive: Hive, boxName: 'never_opened');
      expect(fresh.getAll, throwsA(isA<CacheException>()));
      await fresh.close();
    });
  });

  group('saveAll', () {
    test('stores and reads back a day', () async {
      await storage.saveAll([
        record('2026-09-01', 'fajr', '04:30:00'),
        record('2026-09-01', 'dhuhr', '12:00:00'),
      ]);

      final stored = storage.getByDate('2026-09-01');
      expect(stored, hasLength(2));
      expect(stored.map((r) => r.prayerId), ['fajr', 'dhuhr']);
    });

    test('saving the same day twice does not duplicate rows', () async {
      // Regression: the SQLite version issued a raw INSERT with no uniqueness
      // constraint, so re-seeding a date silently doubled every row and
      // inflated every statistic.
      final day = [
        record('2026-09-01', 'fajr', '04:30:00'),
        record('2026-09-01', 'dhuhr', '12:00:00'),
      ];

      await storage.saveAll(day);
      await storage.saveAll(day);
      await storage.saveAll(day);

      expect(storage.getByDate('2026-09-01'), hasLength(2));
      expect(storage.getAll(), hasLength(2));
    });

    test('re-saving a day keeps a status the user already recorded', () async {
      await storage.saveAll([record('2026-09-01', 'fajr', '04:30:00')]);
      await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'congregation',
      );

      // A re-seed refreshes the computed time but must not wipe user data.
      await storage.saveAll([record('2026-09-01', 'fajr', '04:31:00')]);

      final stored = storage.getByDate('2026-09-01').single;
      expect(stored.statusId, 'congregation');
      expect(stored.timeIso, '2026-09-01T04:31:00');
    });

    test('accepts an empty list', () async {
      await storage.saveAll([]);
      expect(storage.getAll(), isEmpty);
    });

    test('returns a day sorted chronologically regardless of write order',
        () async {
      await storage.saveAll([
        record('2026-09-01', 'isha', '20:00:00'),
        record('2026-09-01', 'fajr', '04:30:00'),
        record('2026-09-01', 'asr', '15:30:00'),
      ]);

      expect(
        storage.getByDate('2026-09-01').map((r) => r.prayerId),
        ['fajr', 'asr', 'isha'],
      );
    });
  });

  group('getByDate', () {
    test('returns an empty list for an unseeded day', () {
      expect(storage.getByDate('2030-01-01'), isEmpty);
    });

    test('does not leak rows from neighbouring days', () async {
      await storage.saveAll([
        record('2026-08-31', 'fajr', '04:29:00'),
        record('2026-09-01', 'fajr', '04:30:00'),
        record('2026-09-02', 'fajr', '04:31:00'),
      ]);

      expect(storage.getByDate('2026-09-01'), hasLength(1));
    });
  });

  group('getInRange', () {
    setUp(() async {
      await storage.saveAll([
        for (var day = 1; day <= 5; day++)
          record('2026-09-0$day', 'fajr', '04:30:00'),
      ]);
    });

    test('includes both bounds', () {
      final result = storage.getInRange('2026-09-02', '2026-09-04');
      expect(
        result.map((r) => r.dateKey),
        ['2026-09-02', '2026-09-03', '2026-09-04'],
      );
    });

    test('returns a single day when the bounds match', () {
      expect(storage.getInRange('2026-09-03', '2026-09-03'), hasLength(1));
    });

    test('returns nothing for an inverted range', () {
      expect(storage.getInRange('2026-09-04', '2026-09-02'), isEmpty);
    });

    test('spans a month boundary', () async {
      await storage.saveAll([record('2026-10-01', 'fajr', '05:00:00')]);
      expect(storage.getInRange('2026-09-04', '2026-10-01'), hasLength(3));
    });
  });

  group('updateStatus', () {
    setUp(() async {
      await storage.saveAll([record('2026-09-01', 'fajr', '04:30:00')]);
    });

    test('records a status and returns the updated record', () async {
      final updated = await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'late',
      );

      expect(updated!.statusId, 'late');
      expect(storage.getByDate('2026-09-01').single.statusId, 'late');
    });

    test('overwrites a previously recorded status', () async {
      await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'late',
      );
      await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'congregation',
      );

      expect(storage.getByDate('2026-09-01').single.statusId, 'congregation');
    });

    test('clears a status when passed null', () async {
      await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'late',
      );
      final cleared = await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: null,
      );

      expect(cleared!.statusId, isNull);
    });

    test('returns null for a prayer that does not exist', () async {
      final result = await storage.updateStatus(
        dateKey: '2030-01-01',
        prayerId: 'fajr',
        statusId: 'late',
      );
      expect(result, isNull);
    });
  });

  group('onStatusChanged', () {
    test('emits when the user records a status', () async {
      await storage.saveAll([record('2026-09-01', 'fajr', '04:30:00')]);

      final emissions = <void>[];
      final subscription = storage.onStatusChanged.listen(emissions.add);

      await storage.updateStatus(
        dateKey: '2026-09-01',
        prayerId: 'fajr',
        statusId: 'late',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emissions, hasLength(1));
      await subscription.cancel();
    });

    test('does not emit while seeding computed times', () async {
      // Seeding writes ~300 records at start-up; emitting for each of them is
      // what made the old statistics screen recompute continuously.
      final emissions = <void>[];
      final subscription = storage.onStatusChanged.listen(emissions.add);

      await storage.saveAll([
        for (var day = 1; day <= 9; day++)
          record('2026-09-0$day', 'fajr', '04:30:00'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, isEmpty);
      await subscription.cancel();
    });
  });
}
