import 'package:equatable/equatable.dart';

/// The day the prayer screen is showing. Future dates are not selectable —
/// the app tracks what you did, not what you will do.
class SelectedDateState extends Equatable {
  final DateTime date;

  const SelectedDateState(this.date);

  @override
  List<Object?> get props => [date];
}
