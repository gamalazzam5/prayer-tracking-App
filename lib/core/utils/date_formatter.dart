/// Date helpers shared across features.
///
/// Pure Dart — no Flutter imports, safe to use from the domain layer.
class DateFormatter {
  DateFormatter._();

  static const List<String> gregorianMonthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> hijriMonthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  /// `2026-09-01` — the storage key format. Lexicographic order matches
  /// chronological order, which range queries rely on.
  static String toKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// `01 سبتمبر 2026` — what the date navigator shows.
  static String toArabicLabel(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${gregorianMonthsAr[date.month - 1]} ${date.year}';
  }

  /// `05:31` in 24h form.
  static String toClockLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// `02:59` — 12-hour clock, to be shown together with [meridiem].
  ///
  /// Pairing the 24-hour [toClockLabel] with an AM/PM suffix produced labels
  /// like "14:59 PM"; the two must come from the same clock convention.
  static String toTwelveHourLabel(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${hour12.toString().padLeft(2, '0')}:$minute';
  }

  /// ` AM` / ` PM` suffix for a given time.
  static String meridiem(DateTime time) => time.hour >= 12 ? ' PM' : ' AM';

  /// Midnight of [date], dropping any time component.
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// True when both instants fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// `H:MM:SS` countdown label for a positive duration.
  static String toCountdown(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '${safe.inHours}:$minutes:$seconds';
  }
}
