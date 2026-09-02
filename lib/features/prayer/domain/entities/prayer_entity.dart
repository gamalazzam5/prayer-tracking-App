import 'package:equatable/equatable.dart';

import 'prayer_name.dart';
import 'prayer_status.dart';

/// One prayer on one day: when it is due and how the user performed it.
class PrayerEntity extends Equatable {
  final PrayerName name;

  /// Local wall-clock time the prayer becomes due.
  final DateTime time;

  /// Null until the user records how they prayed.
  final PrayerStatus? status;

  const PrayerEntity({
    required this.name,
    required this.time,
    this.status,
  });

  bool get isRecorded => status != null;

  /// Same prayer, moved to a different instant. Used when the next prayer is
  /// tomorrow's and no computed time for it is on hand.
  PrayerEntity copyWithTime(DateTime time) =>
      PrayerEntity(name: name, time: time, status: status);

  PrayerEntity copyWith({PrayerStatus? status, bool clearStatus = false}) =>
      PrayerEntity(
        name: name,
        time: time,
        status: clearStatus ? null : (status ?? this.status),
      );

  @override
  List<Object?> get props => [name, time, status];
}
