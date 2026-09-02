import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../../../../core/error/exceptions.dart';
import '../../../../core/location/coordinates.dart';
import '../../domain/entities/prayer_name.dart';
import '../models/prayer_model.dart';

/// Computes prayer times for a date and location.
///
/// Wraps `adhan_dart` behind an interface so the repository — and its tests —
/// never touch the third-party API directly.
abstract class PrayerTimeCalculator {
  List<PrayerModel> calculate({
    required DateTime date,
    required Coordinates coordinates,
  });
}

class AdhanPrayerTimeCalculator implements PrayerTimeCalculator {
  const AdhanPrayerTimeCalculator();

  @override
  List<PrayerModel> calculate({
    required DateTime date,
    required Coordinates coordinates,
  }) {
    try {
      final times = adhan.PrayerTimes(
        coordinates: adhan.Coordinates(
          coordinates.latitude,
          coordinates.longitude,
        ),
        // Normalised to midnight: adhan derives the solar day from the date
        // part, and passing a time component shifts results near midnight.
        date: DateTime(date.year, date.month, date.day),
        calculationParameters: adhan.CalculationMethod.egyptian(),
        precision: true,
      );

      final byName = <PrayerName, DateTime?>{
        PrayerName.fajr: times.fajr,
        PrayerName.dhuhr: times.dhuhr,
        PrayerName.asr: times.asr,
        PrayerName.maghrib: times.maghrib,
        PrayerName.isha: times.isha,
      };

      final prayers = <PrayerModel>[];
      for (final entry in byName.entries) {
        final time = entry.value;
        if (time == null) {
          throw PrayerCalculationException(
            'adhan returned no time for ${entry.key.id}',
          );
        }
        prayers.add(PrayerModel(name: entry.key, time: time.toLocal()));
      }
      return prayers;
    } on PrayerCalculationException {
      rethrow;
    } catch (e) {
      throw PrayerCalculationException('$e');
    }
  }
}
