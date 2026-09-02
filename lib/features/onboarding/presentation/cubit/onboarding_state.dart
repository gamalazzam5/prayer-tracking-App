import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int pageIndex;

  /// Set once the user finishes or skips; the screen navigates away on it.
  final bool isCompleted;

  const OnboardingState({this.pageIndex = 0, this.isCompleted = false});

  OnboardingState copyWith({int? pageIndex, bool? isCompleted}) =>
      OnboardingState(
        pageIndex: pageIndex ?? this.pageIndex,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [pageIndex, isCompleted];
}
