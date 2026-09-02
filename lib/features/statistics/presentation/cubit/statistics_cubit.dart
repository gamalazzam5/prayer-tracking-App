import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_statistics_usecase.dart';
import '../../domain/usecases/watch_statistics_changes_usecase.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetStatisticsUseCase _getStatistics;
  final WatchStatisticsChangesUseCase _watchChanges;

  StreamSubscription<void>? _subscription;

  StatisticsCubit({
    required GetStatisticsUseCase getStatistics,
    required WatchStatisticsChangesUseCase watchChanges,
  })  : _getStatistics = getStatistics,
        _watchChanges = watchChanges,
        super(const StatisticsInitial());

  /// Loads the statistics and keeps them in sync with recorded prayers.
  Future<void> start() async {
    _subscription ??= _watchChanges().listen((_) => loadStatistics());
    await loadStatistics();
  }

  Future<void> loadStatistics() async {
    if (isClosed) return;
    // Only show the spinner on the first load; a refresh triggered by a
    // recorded prayer should not blank the screen the user is looking at.
    if (state is! StatisticsLoaded) emit(const StatisticsLoading());

    final result = await _getStatistics();
    if (isClosed) return;

    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (statistics) => emit(StatisticsLoaded(statistics)),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
