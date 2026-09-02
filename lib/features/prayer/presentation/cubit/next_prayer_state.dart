import 'package:equatable/equatable.dart';

import '../../domain/entities/next_prayer_entity.dart';

sealed class NextPrayerState extends Equatable {
  const NextPrayerState();

  @override
  List<Object?> get props => [];
}

class NextPrayerUnavailable extends NextPrayerState {
  const NextPrayerUnavailable();
}

class NextPrayerReady extends NextPrayerState {
  final NextPrayerEntity nextPrayer;

  /// Formatted Hijri date shown alongside the countdown.
  final String hijriDate;

  const NextPrayerReady({required this.nextPrayer, required this.hijriDate});

  @override
  List<Object?> get props => [nextPrayer, hijriDate];
}
