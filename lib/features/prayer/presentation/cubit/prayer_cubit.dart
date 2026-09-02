import 'package:bloc/bloc.dart';

import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_status.dart';
import '../../domain/usecases/get_prayers_for_date_usecase.dart';
import '../../domain/usecases/update_prayer_status_usecase.dart';
import 'prayer_state.dart';

/// Drives the prayer list. Depends only on use cases, never on repositories.
class PrayerCubit extends Cubit<PrayerState> {
  final GetPrayersForDateUseCase _getPrayersForDate;
  final UpdatePrayerStatusUseCase _updatePrayerStatus;

  PrayerCubit({
    required GetPrayersForDateUseCase getPrayersForDate,
    required UpdatePrayerStatusUseCase updatePrayerStatus,
  })  : _getPrayersForDate = getPrayersForDate,
        _updatePrayerStatus = updatePrayerStatus,
        super(const PrayerInitial());

  Future<void> loadPrayers(DateTime date) async {
    emit(const PrayerLoading());
    final result = await _getPrayersForDate(date);
    if (isClosed) return;
    result.fold(
      (failure) => emit(PrayerError(failure.message)),
      (prayers) => emit(PrayerLoaded(prayers: prayers, date: date)),
    );
  }

  /// Records a status and patches it into the loaded list in place, so the tile
  /// updates without a full reload.
  Future<void> recordStatus({
    required PrayerEntity prayer,
    required PrayerStatus? status,
  }) async {
    final current = state;
    if (current is! PrayerLoaded) return;

    final result = await _updatePrayerStatus(
      date: current.date,
      prayer: prayer,
      status: status,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(PrayerError(failure.message)),
      (updated) => emit(PrayerLoaded(
        date: current.date,
        prayers: [
          for (final item in current.prayers)
            item.name == updated.name ? updated : item,
        ],
      )),
    );
  }
}
