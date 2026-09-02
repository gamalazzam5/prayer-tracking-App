/// Flat, storage-shaped view of a single tracked prayer.
///
/// Deliberately primitive (no Hive, no Flutter) so the storage contract can be
/// implemented by any backend and faked in tests.
class PrayerRecord {
  /// `yyyy-MM-dd`, see [DateFormatter.toKey].
  final String dateKey;

  /// Stable identifier — `fajr`, `dhuhr`, `asr`, `maghrib`, `isha`.
  /// Never a localised display name: those change, keys must not.
  final String prayerId;

  /// Prayer time as an ISO-8601 string in local time.
  final String timeIso;

  /// Stable status id — `missed`, `late`, `alone`, `congregation` — or null
  /// when the user has not recorded this prayer yet.
  final String? statusId;

  const PrayerRecord({
    required this.dateKey,
    required this.prayerId,
    required this.timeIso,
    this.statusId,
  });

  /// Composite primary key, unique per (day, prayer). Writing under this key
  /// makes every save idempotent — the duplicate-row bug the SQLite version
  /// had is structurally impossible here.
  String get storageKey => '$dateKey|$prayerId';

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'prayerId': prayerId,
        'timeIso': timeIso,
        'statusId': statusId,
      };

  factory PrayerRecord.fromMap(Map<dynamic, dynamic> map) => PrayerRecord(
        dateKey: map['dateKey'] as String,
        prayerId: map['prayerId'] as String,
        timeIso: map['timeIso'] as String,
        statusId: map['statusId'] as String?,
      );

  PrayerRecord copyWith({String? statusId, bool clearStatus = false}) =>
      PrayerRecord(
        dateKey: dateKey,
        prayerId: prayerId,
        timeIso: timeIso,
        statusId: clearStatus ? null : (statusId ?? this.statusId),
      );
}
