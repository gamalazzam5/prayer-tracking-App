import 'package:depi1/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toKey', () {
    test('zero-pads month and day', () {
      expect(DateFormatter.toKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(DateFormatter.toKey(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('ignores the time component', () {
      expect(
        DateFormatter.toKey(DateTime(2026, 9, 1, 23, 59, 59)),
        '2026-09-01',
      );
    });

    test('sorts lexicographically in chronological order', () {
      // Range queries over the store depend on this property.
      final keys = [
        DateTime(2026, 9, 10),
        DateTime(2026, 1, 2),
        DateTime(2025, 12, 31),
        DateTime(2026, 9, 2),
      ].map(DateFormatter.toKey).toList()
        ..sort();

      expect(keys, [
        '2025-12-31',
        '2026-01-02',
        '2026-09-02',
        '2026-09-10',
      ]);
    });
  });

  group('toArabicLabel', () {
    test('uses the Arabic month name', () {
      expect(
        DateFormatter.toArabicLabel(DateTime(2026, 9, 1)),
        '01 سبتمبر 2026',
      );
    });

    test('covers every month without an index error', () {
      for (var month = 1; month <= 12; month++) {
        expect(DateFormatter.toArabicLabel(DateTime(2026, month, 1)),
            isNotEmpty);
      }
    });
  });

  group('toClockLabel', () {
    test('zero-pads both hour and minute', () {
      expect(DateFormatter.toClockLabel(DateTime(2026, 9, 1, 4, 5)), '04:05');
    });

    test('uses 24-hour form', () {
      expect(DateFormatter.toClockLabel(DateTime(2026, 9, 1, 20, 0)), '20:00');
      expect(DateFormatter.toClockLabel(DateTime(2026, 9, 1, 0, 0)), '00:00');
    });
  });

  group('toTwelveHourLabel', () {
    test('converts afternoon hours to the 12-hour clock', () {
      // Regression: the tile paired the 24-hour clock with an AM/PM suffix and
      // rendered times like "14:59 PM".
      expect(
        DateFormatter.toTwelveHourLabel(DateTime(2026, 9, 1, 14, 59)),
        '02:59',
      );
    });

    test('renders noon and midnight as 12, not 00', () {
      expect(
        DateFormatter.toTwelveHourLabel(DateTime(2026, 9, 1, 12, 0)),
        '12:00',
      );
      expect(
        DateFormatter.toTwelveHourLabel(DateTime(2026, 9, 1, 0, 30)),
        '12:30',
      );
    });

    test('keeps morning hours unchanged', () {
      expect(
        DateFormatter.toTwelveHourLabel(DateTime(2026, 9, 1, 4, 5)),
        '04:05',
      );
    });

    test('paired with meridiem it is never self-contradictory', () {
      for (var hour = 0; hour < 24; hour++) {
        final time = DateTime(2026, 9, 1, hour);
        final label = DateFormatter.toTwelveHourLabel(time);
        final hourPart = int.parse(label.split(':').first);
        expect(hourPart, inInclusiveRange(1, 12), reason: 'at hour $hour');
      }
    });
  });

  group('meridiem', () {
    test('splits at noon', () {
      expect(DateFormatter.meridiem(DateTime(2026, 9, 1, 11, 59)), ' AM');
      expect(DateFormatter.meridiem(DateTime(2026, 9, 1, 12, 0)), ' PM');
    });
  });

  group('isSameDay', () {
    test('matches different times on the same date', () {
      expect(
        DateFormatter.isSameDay(
          DateTime(2026, 9, 1, 0, 1),
          DateTime(2026, 9, 1, 23, 59),
        ),
        isTrue,
      );
    });

    test('rejects the same day number in a different month or year', () {
      expect(
        DateFormatter.isSameDay(DateTime(2026, 9, 1), DateTime(2026, 10, 1)),
        isFalse,
      );
      expect(
        DateFormatter.isSameDay(DateTime(2025, 9, 1), DateTime(2026, 9, 1)),
        isFalse,
      );
    });
  });

  group('toCountdown', () {
    test('formats hours, minutes and seconds', () {
      expect(
        DateFormatter.toCountdown(
          const Duration(hours: 2, minutes: 5, seconds: 9),
        ),
        '2:05:09',
      );
    });

    test('shows zero for an elapsed duration rather than a negative clock', () {
      expect(DateFormatter.toCountdown(const Duration(seconds: -30)), '0:00:00');
    });

    test('does not roll hours over at 24', () {
      expect(DateFormatter.toCountdown(const Duration(hours: 25)), '25:00:00');
    });
  });

  group('startOfDay', () {
    test('drops the time component', () {
      expect(
        DateFormatter.startOfDay(DateTime(2026, 9, 1, 15, 42, 7)),
        DateTime(2026, 9, 1),
      );
    });
  });
}
