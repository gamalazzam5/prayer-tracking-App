import 'package:depi1/features/prayer/domain/entities/prayer_entity.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_name.dart';
import 'package:depi1/features/prayer/domain/usecases/resolve_next_prayer_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = ResolveNextPrayerUseCase();

  PrayerEntity prayerAt(PrayerName name, int hour, int minute) => PrayerEntity(
        name: name,
        time: DateTime(2026, 9, 1, hour, minute),
      );

  final day = [
    prayerAt(PrayerName.fajr, 4, 30),
    prayerAt(PrayerName.dhuhr, 12, 0),
    prayerAt(PrayerName.asr, 15, 30),
    prayerAt(PrayerName.maghrib, 18, 30),
    prayerAt(PrayerName.isha, 20, 0),
  ];

  group('ResolveNextPrayerUseCase', () {
    test('returns null for an empty day instead of throwing', () {
      // Regression: the previous controller indexed straight into the list on
      // every timer tick and threw a RangeError whenever loading had failed.
      expect(useCase(const [], DateTime(2026, 9, 1, 10)), isNull);
    });

    test('picks Fajr before the day starts', () {
      final result = useCase(day, DateTime(2026, 9, 1, 3));
      expect(result!.prayer.name, PrayerName.fajr);
      expect(result.index, 0);
      expect(result.isTomorrow, isFalse);
      expect(result.remaining, const Duration(hours: 1, minutes: 30));
    });

    test('picks the next prayer mid-day', () {
      final result = useCase(day, DateTime(2026, 9, 1, 13));
      expect(result!.prayer.name, PrayerName.asr);
      expect(result.index, 2);
      expect(result.remaining, const Duration(hours: 2, minutes: 30));
    });

    test('picks a prayer whose time is one second away', () {
      final result = useCase(day, DateTime(2026, 9, 1, 11, 59, 59));
      expect(result!.prayer.name, PrayerName.dhuhr);
      expect(result.remaining, const Duration(seconds: 1));
    });

    test('skips a prayer at exactly its due time', () {
      // Due "now" means it has started, so the next one is Asr.
      final result = useCase(day, DateTime(2026, 9, 1, 12, 0, 0));
      expect(result!.prayer.name, PrayerName.asr);
    });

    test('rolls over to tomorrow Fajr once Isha has passed', () {
      final result = useCase(day, DateTime(2026, 9, 1, 22));
      expect(result!.prayer.name, PrayerName.fajr);
      expect(result.index, 0);
      expect(result.isTomorrow, isTrue);
      expect(result.prayer.time, DateTime(2026, 9, 2, 4, 30));
      expect(result.remaining, const Duration(hours: 6, minutes: 30));
    });

    test('uses tomorrow real Fajr once Isha has passed, when it is known', () {
      // Prayer times shift by a few minutes each day, and by a full hour
      // across a DST change: adding 24 hours to today's Fajr is not enough.
      final tomorrow = [
        prayerAt(PrayerName.fajr, 4, 32),
        prayerAt(PrayerName.dhuhr, 12, 0),
      ].map((p) => PrayerEntity(
            name: p.name,
            time: p.time.add(const Duration(days: 1)),
          )).toList();

      final result = useCase(day, DateTime(2026, 9, 1, 22), tomorrow: tomorrow);

      expect(result!.isTomorrow, isTrue);
      expect(result.prayer.time, DateTime(2026, 9, 2, 4, 32));
      expect(result.remaining, const Duration(hours: 6, minutes: 32));
    });

    test('falls back to a 24-hour shift when tomorrow is unknown', () {
      final result = useCase(day, DateTime(2026, 9, 1, 22), tomorrow: const []);

      expect(result!.prayer.time, DateTime(2026, 9, 2, 4, 30));
    });

    test('ignores tomorrow while prayers remain today', () {
      final tomorrow = [prayerAt(PrayerName.fajr, 4, 32)];

      final result = useCase(day, DateTime(2026, 9, 1, 13), tomorrow: tomorrow);

      expect(result!.prayer.name, PrayerName.asr);
      expect(result.isTomorrow, isFalse);
    });

    test('never returns a negative countdown', () {
      for (var hour = 0; hour < 24; hour++) {
        final result = useCase(day, DateTime(2026, 9, 1, hour));
        expect(result!.remaining.isNegative, isFalse, reason: 'at hour $hour');
      }
    });
  });
}
