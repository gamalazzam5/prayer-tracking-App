import 'package:equatable/equatable.dart';

import 'prayer_entity.dart';

/// The upcoming prayer and how long is left until it.
class NextPrayerEntity extends Equatable {
  final PrayerEntity prayer;

  /// Index of [prayer] within the day's list — the prayer list highlights it.
  final int index;

  /// Time remaining until [prayer] is due. Never negative.
  final Duration remaining;

  /// True when the whole of today has passed and [prayer] is tomorrow's Fajr.
  final bool isTomorrow;

  const NextPrayerEntity({
    required this.prayer,
    required this.index,
    required this.remaining,
    required this.isTomorrow,
  });

  @override
  List<Object?> get props => [prayer, index, remaining, isTomorrow];
}
