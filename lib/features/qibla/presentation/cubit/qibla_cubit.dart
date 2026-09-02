import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/watch_qibla_direction_usecase.dart';
import 'qibla_state.dart';

/// Subscribes to the qibla feed and exposes it as UI state.
class QiblaCubit extends Cubit<QiblaState> {
  final WatchQiblaDirectionUseCase _watchQiblaDirection;

  StreamSubscription<void>? _subscription;

  QiblaCubit({required WatchQiblaDirectionUseCase watchQiblaDirection})
      : _watchQiblaDirection = watchQiblaDirection,
        super(const QiblaInitial());

  /// Starts (or restarts, after a retry) the compass subscription.
  Future<void> start() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const QiblaLoading());

    _subscription = _watchQiblaDirection().listen(
      (result) {
        if (isClosed) return;
        result.fold(
          (failure) => emit(QiblaError(
            failure.message,
            isRecoverable: failure is! CompassUnavailableFailure,
          )),
          (direction) => emit(QiblaReady(direction)),
        );
      },
      onError: (Object _) {
        if (isClosed) return;
        emit(const QiblaError('تعذر قراءة البوصلة'));
      },
    );
  }

  /// Releases the compass subscription while the qibla tab is off screen.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (!isClosed) emit(const QiblaInitial());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
