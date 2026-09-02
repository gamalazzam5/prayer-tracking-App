import 'package:bloc/bloc.dart';

import '../../../../core/utils/date_formatter.dart';
import 'selected_date_state.dart';

/// Owns the currently viewed day for the prayer screen.
class SelectedDateCubit extends Cubit<SelectedDateState> {
  /// Injected so tests can pin "now" instead of depending on the wall clock.
  final DateTime Function() _now;

  SelectedDateCubit({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(SelectedDateState(
          DateFormatter.startOfDay((now ?? DateTime.now)()),
        ));

  DateTime get _today => DateFormatter.startOfDay(_now());

  /// True while there is a later day the user is still allowed to view.
  bool get canGoForward => state.date.isBefore(_today);

  void goToPreviousDay() => _moveBy(-1);

  void goToNextDay() {
    if (!canGoForward) return;
    _moveBy(1);
  }

  void goToToday() => emit(SelectedDateState(_today));

  void _moveBy(int days) {
    final target = state.date.add(Duration(days: days));
    // Guard the forward edge here too, so a direct call cannot outrun today.
    if (target.isAfter(_today)) return;
    emit(SelectedDateState(target));
  }
}
