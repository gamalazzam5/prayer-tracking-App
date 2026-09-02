import 'package:equatable/equatable.dart';

import '../../domain/entities/qibla_direction_entity.dart';

sealed class QiblaState extends Equatable {
  const QiblaState();

  @override
  List<Object?> get props => [];
}

class QiblaInitial extends QiblaState {
  const QiblaInitial();
}

class QiblaLoading extends QiblaState {
  const QiblaLoading();
}

class QiblaReady extends QiblaState {
  final QiblaDirectionEntity direction;

  const QiblaReady(this.direction);

  @override
  List<Object?> get props => [direction];
}

class QiblaError extends QiblaState {
  final String message;

  /// True when the user can fix this by granting permission or enabling GPS,
  /// so the view offers a retry.
  final bool isRecoverable;

  const QiblaError(this.message, {this.isRecoverable = true});

  @override
  List<Object?> get props => [message, isRecoverable];
}
