import 'package:hijri/hijri_calendar.dart';

import 'date_formatter.dart';

/// Formats a Gregorian date as an Arabic Hijri label, e.g. `9 ربيع الأول 1448 هـ`.
class HijriFormatter {
  HijriFormatter._();

  static String format(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthIndex = hijri.hMonth - 1;
    // Defensive: never index out of the month table if the library ever
    // returns something unexpected.
    if (monthIndex < 0 || monthIndex >= DateFormatter.hijriMonthsAr.length) {
      return '${hijri.hDay} ${hijri.hYear} هـ';
    }
    return '${hijri.hDay} ${DateFormatter.hijriMonthsAr[monthIndex]} '
        '${hijri.hYear} هـ';
  }
}
