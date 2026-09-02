import 'package:equatable/equatable.dart';

/// Progress over the last seven days.
class WeeklyAchievementEntity extends Equatable {
  /// Prayers recorded as performed (on time, late or in congregation).
  final int performed;

  /// Prayers expected over the window — seven days of five prayers.
  final int target;

  const WeeklyAchievementEntity({
    required this.performed,
    required this.target,
  });

  /// Completion in `[0, 1]`, clamped so a data anomaly cannot exceed 100%.
  double get progress {
    if (target <= 0) return 0;
    return (performed / target).clamp(0.0, 1.0);
  }

  bool get isComplete => performed >= target;

  @override
  List<Object?> get props => [performed, target];
}
