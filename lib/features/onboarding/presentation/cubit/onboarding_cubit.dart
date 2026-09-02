import 'package:bloc/bloc.dart';

import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboarding;

  OnboardingCubit({required CompleteOnboardingUseCase completeOnboarding})
      : _completeOnboarding = completeOnboarding,
        super(const OnboardingState());

  void onPageChanged(int index) => emit(state.copyWith(pageIndex: index));

  /// Marks the intro as seen and signals the screen to move on. A storage
  /// failure is deliberately not surfaced: the worst case is seeing the intro
  /// once more, which should not block entry to the app.
  Future<void> complete() async {
    await _completeOnboarding();
    if (isClosed) return;
    emit(state.copyWith(isCompleted: true));
  }
}
