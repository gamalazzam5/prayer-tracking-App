import 'prayer_record.dart';

/// Storage contract for tracked prayers.
///
/// Lives in `core/` because both the prayer and statistics features read
/// through it. Implementations catch nothing — they throw [CacheException] and
/// let repositories map that to a [Failure].
abstract class PrayerLocalStorage {
  /// Opens the underlying store. Must complete before any other call.
  Future<void> init();

  /// Upserts [records] by their composite key. Existing rows keep their
  /// recorded status: only the computed time is refreshed.
  Future<void> saveAll(List<PrayerRecord> records);

  /// All records for one day, in insertion (chronological) order.
  List<PrayerRecord> getByDate(String dateKey);

  /// All records whose `dateKey` falls in `[startKey, endKey]`, inclusive.
  /// Both bounds use the `yyyy-MM-dd` format, which sorts chronologically.
  List<PrayerRecord> getInRange(String startKey, String endKey);

  /// Every record in the store.
  List<PrayerRecord> getAll();

  /// Records the user's status for one prayer. Returns the updated record, or
  /// null when no such prayer exists.
  Future<PrayerRecord?> updateStatus({
    required String dateKey,
    required String prayerId,
    required String? statusId,
  });

  /// Emits whenever a status is recorded. Seeding computed times does *not*
  /// emit — only user-visible changes do, so listeners are not flooded during
  /// start-up.
  Stream<void> get onStatusChanged;

  /// Releases the store. Safe to call more than once.
  Future<void> close();
}
