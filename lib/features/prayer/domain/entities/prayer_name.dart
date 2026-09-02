/// The five daily obligatory prayers, in chronological order.
enum PrayerName {
  fajr('fajr', 'الفجر', 'Fajr'),
  dhuhr('dhuhr', 'الظهر', 'Dhuhr'),
  asr('asr', 'العصر', 'Asr'),
  maghrib('maghrib', 'المغرب', 'Maghrib'),
  isha('isha', 'العشاء', 'Isha');

  /// Stable persisted identifier.
  final String id;

  /// Arabic display name.
  final String arabicName;

  /// English display name.
  final String englishName;

  const PrayerName(this.id, this.arabicName, this.englishName);

  static PrayerName? fromId(String? id) {
    if (id == null) return null;
    for (final name in PrayerName.values) {
      if (name.id == id) return name;
    }
    return null;
  }
}
