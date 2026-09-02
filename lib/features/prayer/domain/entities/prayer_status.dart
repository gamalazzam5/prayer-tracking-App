/// How the user performed a prayer.
///
/// The [id] is what gets persisted — never the Arabic label. Storing display
/// text was a defect in the previous version: renaming a label would have
/// orphaned every historical row.
enum PrayerStatus {
  missed('missed'),
  late('late'),
  alone('alone'),
  congregation('congregation');

  final String id;

  const PrayerStatus(this.id);

  /// Parses a persisted id, returning null for null/unknown values rather than
  /// throwing, so one bad row cannot break a whole day's read.
  static PrayerStatus? fromId(String? id) {
    if (id == null) return null;
    for (final status in PrayerStatus.values) {
      if (status.id == id) return status;
    }
    return null;
  }

  /// Statuses that count as "the prayer was performed".
  static const Set<PrayerStatus> performed = {
    PrayerStatus.late,
    PrayerStatus.alone,
    PrayerStatus.congregation,
  };

  bool get isPerformed => performed.contains(this);
}
