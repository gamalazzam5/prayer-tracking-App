import 'package:bloc_test/bloc_test.dart';
import 'package:salaty/features/prayer/presentation/cubit/selected_date_cubit.dart';
import 'package:salaty/features/prayer/presentation/cubit/selected_date_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Mid-afternoon, so the "start of day" normalisation is actually exercised.
  final now = DateTime(2026, 9, 1, 15, 42);
  final today = DateTime(2026, 9, 1);

  SelectedDateCubit buildCubit() => SelectedDateCubit(now: () => now);

  group('SelectedDateCubit', () {
    test('starts on today with the time component stripped', () {
      expect(buildCubit().state.date, today);
    });

    blocTest<SelectedDateCubit, SelectedDateState>(
      'steps backwards',
      build: buildCubit,
      act: (cubit) => cubit.goToPreviousDay(),
      expect: () => [SelectedDateState(DateTime(2026, 8, 31))],
    );

    blocTest<SelectedDateCubit, SelectedDateState>(
      'steps across a month boundary',
      build: buildCubit,
      act: (cubit) {
        cubit.goToPreviousDay();
        cubit.goToPreviousDay();
      },
      expect: () => [
        SelectedDateState(DateTime(2026, 8, 31)),
        SelectedDateState(DateTime(2026, 8, 30)),
      ],
    );

    blocTest<SelectedDateCubit, SelectedDateState>(
      'refuses to move past today',
      build: buildCubit,
      act: (cubit) => cubit.goToNextDay(),
      expect: () => <SelectedDateState>[],
    );

    blocTest<SelectedDateCubit, SelectedDateState>(
      'steps forward again after going back',
      build: buildCubit,
      act: (cubit) {
        cubit.goToPreviousDay();
        cubit.goToNextDay();
      },
      expect: () => [
        SelectedDateState(DateTime(2026, 8, 31)),
        SelectedDateState(today),
      ],
    );

    test('canGoForward is false on today and true in the past', () {
      final cubit = buildCubit();
      expect(cubit.canGoForward, isFalse);

      cubit.goToPreviousDay();
      expect(cubit.canGoForward, isTrue);
    });

    blocTest<SelectedDateCubit, SelectedDateState>(
      'goToToday returns from a past date',
      build: buildCubit,
      act: (cubit) {
        cubit.goToPreviousDay();
        cubit.goToPreviousDay();
        cubit.goToToday();
      },
      expect: () => [
        SelectedDateState(DateTime(2026, 8, 31)),
        SelectedDateState(DateTime(2026, 8, 30)),
        SelectedDateState(today),
      ],
    );
  });
}
