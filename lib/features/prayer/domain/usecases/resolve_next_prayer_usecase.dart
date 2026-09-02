import '../entities/next_prayer_entity.dart';
import '../entities/prayer_entity.dart';

/// Works out which prayer is next and how long is left.
///
/// Pure and synchronous, so the once-per-second countdown costs nothing and the
/// edge cases (empty day, every prayer already passed) are unit-testable.
class ResolveNextPrayerUseCase {
  const ResolveNextPrayerUseCase();

  /// [today] must be a single day's prayers in chronological order.
  ///
  /// [tomorrow] is that same list for the following day. It is used once every
  /// prayer today has passed: adding 24 hours to today's Fajr instead would be
  /// a few minutes out on any day, and a full hour out across a DST change.
  /// When it is unavailable the 24-hour shift is used as a fallback.
  ///
  /// Returns null when [today] is empty — the caller renders an empty state
  /// instead of indexing into nothing, which is what used to crash here.
  NextPrayerEntity? call(
    List<PrayerEntity> today,
    DateTime now, {
    List<PrayerEntity> tomorrow = const [],
  }) {
    if (today.isEmpty) return null;

    for (var i = 0; i < today.length; i++) {
      final prayer = today[i];
      if (prayer.time.isAfter(now)) {
        return NextPrayerEntity(
          prayer: prayer,
          index: i,
          remaining: prayer.time.difference(now),
          isTomorrow: false,
        );
      }
    }

    // Every prayer today is behind us: the next one is tomorrow's Fajr.
    final nextFajr = tomorrow.isNotEmpty
        ? tomorrow.first
        : today.first.copyWithTime(
            today.first.time.add(const Duration(days: 1)),
          );

    return NextPrayerEntity(
      prayer: nextFajr,
      index: 0,
      remaining: nextFajr.time.difference(now),
      isTomorrow: true,
    );
  }
}
