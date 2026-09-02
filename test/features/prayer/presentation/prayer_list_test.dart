import 'package:bloc_test/bloc_test.dart';
import 'package:salaty/features/prayer/domain/entities/next_prayer_entity.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_entity.dart';
import 'package:salaty/features/prayer/domain/entities/prayer_name.dart';
import 'package:salaty/features/prayer/presentation/cubit/next_prayer_cubit.dart';
import 'package:salaty/features/prayer/presentation/cubit/next_prayer_state.dart';
import 'package:salaty/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:salaty/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:salaty/features/prayer/presentation/widgets/prayer_list.dart';
import 'package:salaty/features/prayer/presentation/widgets/prayer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNextPrayerCubit extends MockCubit<NextPrayerState>
    implements NextPrayerCubit {}

class _MockPrayerCubit extends MockCubit<PrayerState> implements PrayerCubit {}

void main() {
  late _MockNextPrayerCubit nextPrayerCubit;
  late _MockPrayerCubit prayerCubit;

  final today = DateTime(2026, 9, 1);

  PrayerEntity prayerAt(PrayerName name, int hour, int minute) =>
      PrayerEntity(name: name, time: DateTime(2026, 9, 1, hour, minute));

  final day = [
    prayerAt(PrayerName.fajr, 4, 30),
    prayerAt(PrayerName.dhuhr, 12, 0),
    prayerAt(PrayerName.asr, 15, 30),
    prayerAt(PrayerName.maghrib, 18, 30),
    prayerAt(PrayerName.isha, 20, 0),
  ];

  setUp(() {
    nextPrayerCubit = _MockNextPrayerCubit();
    prayerCubit = _MockPrayerCubit();
    when(() => prayerCubit.state).thenReturn(
      PrayerLoaded(prayers: day, date: today),
    );

    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(402, 1400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  void seedNextPrayer(NextPrayerState state) {
    when(() => nextPrayerCubit.state).thenReturn(state);
  }

  NextPrayerReady ready({
    required PrayerName name,
    required int index,
    required bool isTomorrow,
  }) =>
      NextPrayerReady(
        nextPrayer: NextPrayerEntity(
          prayer: day.firstWhere((p) => p.name == name),
          index: index,
          remaining: const Duration(hours: 1),
          isTomorrow: isTomorrow,
        ),
        hijriDate: '19 ربيع الأول 1448 هـ',
      );

  Future<void> pumpList(
    WidgetTester tester, {
    required DateTime date,
    required DateTime now,
  }) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(402, 880),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<NextPrayerCubit>.value(value: nextPrayerCubit),
            BlocProvider<PrayerCubit>.value(value: prayerCubit),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PrayerList(prayers: day, date: date, now: () => now),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The prayers whose tile is rendered as the upcoming one.
  List<PrayerName> highlighted(WidgetTester tester) => tester
      .widgetList<PrayerTile>(find.byType(PrayerTile))
      .where((tile) => tile.isNext)
      .map((tile) => tile.prayer.name)
      .toList();

  group('upcoming-prayer highlight', () {
    testWidgets('marks the upcoming prayer on today', (tester) async {
      seedNextPrayer(
        ready(name: PrayerName.asr, index: 2, isTomorrow: false),
      );

      await pumpList(tester, date: today, now: DateTime(2026, 9, 1, 13));
      await tester.pump();

      expect(highlighted(tester), [PrayerName.asr]);
      expect(find.text('استعد للصلاه'), findsOneWidget);
    });

    testWidgets('highlights nothing on a past day', (tester) async {
      // The cubit always describes *today's* upcoming prayer. While the user
      // is browsing history that must not mark anything, or every past day
      // would show a bogus "next prayer".
      seedNextPrayer(
        ready(name: PrayerName.asr, index: 2, isTomorrow: false),
      );

      await pumpList(
        tester,
        date: DateTime(2026, 8, 25),
        now: DateTime(2026, 9, 1, 13),
      );
      await tester.pump();

      expect(highlighted(tester), isEmpty);
      expect(find.text('استعد للصلاه'), findsNothing);
    });

    testWidgets('does not fall back to Fajr once Isha has passed',
        (tester) async {
      // Regression: after the last prayer of the day the old code reset the
      // index to 0, so Fajr — long since prayed — lit up as "upcoming". The
      // next prayer is genuinely tomorrow's Fajr, so today's list marks none.
      seedNextPrayer(
        ready(name: PrayerName.fajr, index: 0, isTomorrow: true),
      );

      await pumpList(tester, date: today, now: DateTime(2026, 9, 1, 22));
      await tester.pump();

      expect(highlighted(tester), isEmpty);
      expect(find.text('استعد للصلاه'), findsNothing);
    });

    testWidgets('highlights nothing while the next prayer is unknown',
        (tester) async {
      seedNextPrayer(const NextPrayerUnavailable());

      await pumpList(tester, date: today, now: DateTime(2026, 9, 1, 13));
      await tester.pump();

      expect(highlighted(tester), isEmpty);
    });

    testWidgets('marks exactly one prayer, never several', (tester) async {
      seedNextPrayer(
        ready(name: PrayerName.maghrib, index: 3, isTomorrow: false),
      );

      await pumpList(tester, date: today, now: DateTime(2026, 9, 1, 17));
      await tester.pump();

      expect(highlighted(tester), hasLength(1));
    });
  });

  group('recording eligibility', () {
    testWidgets('every prayer on a past day can be recorded', (tester) async {
      seedNextPrayer(const NextPrayerUnavailable());

      await pumpList(
        tester,
        date: DateTime(2026, 8, 25),
        now: DateTime(2026, 9, 1, 13),
      );
      await tester.pump();

      final tiles = tester.widgetList<PrayerTile>(find.byType(PrayerTile));
      expect(tiles.every((tile) => tile.canRecord), isTrue);
    });

    testWidgets('only prayers already due can be recorded today',
        (tester) async {
      seedNextPrayer(
        ready(name: PrayerName.asr, index: 2, isTomorrow: false),
      );

      await pumpList(tester, date: today, now: DateTime(2026, 9, 1, 13));
      await tester.pump();

      final recordable = tester
          .widgetList<PrayerTile>(find.byType(PrayerTile))
          .where((tile) => tile.canRecord)
          .map((tile) => tile.prayer.name)
          .toList();

      expect(recordable, [PrayerName.fajr, PrayerName.dhuhr]);
    });
  });
}
