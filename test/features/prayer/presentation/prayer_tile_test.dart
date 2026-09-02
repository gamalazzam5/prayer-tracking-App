import 'package:depi1/features/prayer/domain/entities/prayer_entity.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_name.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_status.dart';
import 'package:depi1/features/prayer/presentation/widgets/prayer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fajr = PrayerEntity(
    name: PrayerName.fajr,
    time: DateTime(2026, 9, 1, 4, 30),
  );

  // Pin the surface to the design size so ScreenUtil scales 1:1 and the test
  // reflects the intended layout rather than the 800x600 default.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views.first;
    view.physicalSize = const Size(402, 880);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    required PrayerEntity prayer,
    bool isNext = false,
    bool canRecord = true,
    ValueChanged<PrayerStatus>? onStatusSelected,
  }) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(402, 880),
        child: MaterialApp(
          home: Scaffold(
            body: PrayerTile(
              prayer: prayer,
              isNext: isNext,
              canRecord: canRecord,
              onStatusSelected: onStatusSelected ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('PrayerTile', () {
    testWidgets('shows the prayer name, time and meridiem', (tester) async {
      await pumpTile(tester, prayer: fajr);
      await tester.pump();

      expect(find.text('الفجر'), findsOneWidget);
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('04:30 AM'), findsOneWidget);
    });

    testWidgets('prompts for a status when none is recorded', (tester) async {
      await pumpTile(tester, prayer: fajr);
      await tester.pump();

      expect(find.text('حدد الحاله'), findsOneWidget);
    });

    testWidgets('shows the recorded status instead of the prompt',
        (tester) async {
      await pumpTile(
        tester,
        prayer: fajr.copyWith(status: PrayerStatus.congregation),
      );
      await tester.pump();

      expect(find.text('جماعه'), findsOneWidget);
      expect(find.text('حدد الحاله'), findsNothing);
    });

    testWidgets('shows the prepare prompt for the upcoming prayer',
        (tester) async {
      await pumpTile(tester, prayer: fajr, isNext: true, canRecord: false);
      await tester.pump();

      expect(find.text('استعد للصلاه'), findsOneWidget);
      expect(find.text('حدد الحاله'), findsNothing);
    });

    testWidgets('opens the picker and reports the chosen status',
        (tester) async {
      PrayerStatus? selected;
      await pumpTile(
        tester,
        prayer: fajr,
        onStatusSelected: (status) => selected = status,
      );
      await tester.pump();

      await tester.tap(find.text('حدد الحاله'));
      await tester.pumpAndSettle();

      expect(find.text('كيف صليت الفجر ؟'), findsOneWidget);
      expect(find.text('صليت في جماعه'), findsOneWidget);

      await tester.tap(find.text('صليت في جماعه'));
      await tester.pumpAndSettle();

      expect(selected, PrayerStatus.congregation);
    });

    testWidgets('does not open the picker for a prayer that is not yet due',
        (tester) async {
      await pumpTile(tester, prayer: fajr, canRecord: false);
      await tester.pump();

      await tester.tap(find.text('حدد الحاله'));
      await tester.pumpAndSettle();

      expect(find.text('كيف صليت الفجر ؟'), findsNothing);
    });

    testWidgets('dismissing the picker reports nothing', (tester) async {
      var callbackCount = 0;
      await pumpTile(
        tester,
        prayer: fajr,
        onStatusSelected: (_) => callbackCount++,
      );
      await tester.pump();

      await tester.tap(find.text('حدد الحاله'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(callbackCount, 0);
    });
  });
}
