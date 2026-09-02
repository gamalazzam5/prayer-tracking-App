import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_statistics_entity.dart';

sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final PrayerStatisticsEntity statistics;

  const StatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
