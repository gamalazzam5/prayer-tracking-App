import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_entity.dart';

/// State of the prayer list for the selected day.
sealed class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {
  const PrayerInitial();
}

class PrayerLoading extends PrayerState {
  const PrayerLoading();
}

class PrayerLoaded extends PrayerState {
  final List<PrayerEntity> prayers;

  /// The day these prayers belong to.
  final DateTime date;

  const PrayerLoaded({required this.prayers, required this.date});

  @override
  List<Object?> get props => [prayers, date];
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}
