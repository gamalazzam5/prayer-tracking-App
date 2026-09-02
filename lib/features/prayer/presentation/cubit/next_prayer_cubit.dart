import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/hijri_formatter.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/usecases/get_prayers_for_date_usecase.dart';
import '../../domain/usecases/resolve_next_prayer_usecase.dart';
import 'next_prayer_state.dart';

/// Owns the "next prayer" header: which prayer is coming and the live
/// countdown to it.
///
/// Kept separate from [PrayerCubit] so the once-a-second tick rebuilds only the
/// countdown card, not the whole prayer list.
class NextPrayerCubit extends Cubit<NextPrayerState> {
  final GetPrayersForDateUseCase _getPrayersForDate;
  final ResolveNextPrayerUseCase _resolveNextPrayer;
  final DateTime Function() _now;
  final Duration _tickInterval;

  Timer? _ticker;
  List<PrayerEntity> _todayPrayers = const [];

  /// Tomorrow's prayers, so the post-Isha countdown targets the real Fajr
  /// rather than today's Fajr shifted by 24 hours.
  List<PrayerEntity> _tomorrowPrayers = const [];

  DateTime? _loadedDay;

  /// Guards against re-entrancy: a tick during a midnight reload would
  /// otherwise start another reload every second until the first completed,
  /// because `_loadedDay` is only updated once the await returns.
  bool _isLoading = false;

  NextPrayerCubit({
    required GetPrayersForDateUseCase getPrayersForDate,
    required ResolveNextPrayerUseCase resolveNextPrayer,
    DateTime Function()? now,
    Duration tickInterval = const Duration(seconds: 1),
  })  : _getPrayersForDate = getPrayersForDate,
        _resolveNextPrayer = resolveNextPrayer,
        _now = now ?? DateTime.now,
        _tickInterval = tickInterval,
        super(const NextPrayerUnavailable());

  /// Loads today's prayers and starts the countdown.
  Future<void> start() async {
    await _loadDays();
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => tick());
  }

  /// Recomputes the countdown. Public and synchronous so tests can drive it
  /// directly instead of waiting on a real timer.
  void tick() {
    if (isClosed) return;

    final now = _now();
    final loadedDay = _loadedDay;

    // Midnight rollover: today's prayers are stale, fetch the new day's.
    if (loadedDay != null && !DateFormatter.isSameDay(loadedDay, now)) {
      if (!_isLoading) unawaited(_loadDays());
      return;
    }

    _emitFor(now);
  }

  Future<void> _loadDays() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final now = _now();
      final today = DateFormatter.startOfDay(now);

      final todayResult = await _getPrayersForDate(today);
      if (isClosed) return;

      final loadedToday = todayResult.getOrElse(() => const []);
      if (loadedToday.isEmpty) {
        _todayPrayers = const [];
        _tomorrowPrayers = const [];
        emit(const NextPrayerUnavailable());
        return;
      }

      _todayPrayers = loadedToday;
      _loadedDay = today;

      // Emit straight away so the card appears without waiting on tomorrow;
      // tomorrow only matters after Isha.
      _emitFor(now);

      final tomorrowResult =
          await _getPrayersForDate(today.add(const Duration(days: 1)));
      if (isClosed) return;
      _tomorrowPrayers = tomorrowResult.getOrElse(() => const []);
      _emitFor(_now());
    } finally {
      _isLoading = false;
    }
  }

  void _emitFor(DateTime now) {
    if (isClosed) return;

    final next = _resolveNextPrayer(
      _todayPrayers,
      now,
      tomorrow: _tomorrowPrayers,
    );
    if (next == null) {
      emit(const NextPrayerUnavailable());
      return;
    }
    emit(NextPrayerReady(
      nextPrayer: next,
      hijriDate: HijriFormatter.format(now),
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _ticker = null;
    return super.close();
  }
}
