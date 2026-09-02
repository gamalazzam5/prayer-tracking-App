import 'package:dartz/dartz.dart';
import 'package:depi1/core/error/exceptions.dart';
import 'package:depi1/core/error/failures.dart';
import 'package:depi1/core/location/coordinates.dart';
import 'package:depi1/core/location/location_service.dart';
import 'package:depi1/core/storage/prayer_local_storage.dart';
import 'package:depi1/core/storage/prayer_record.dart';
import 'package:depi1/features/prayer/data/datasources/prayer_time_calculator.dart';
import 'package:depi1/features/prayer/data/models/prayer_model.dart';
import 'package:depi1/features/prayer/data/repos/prayer_repository_impl.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_entity.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_name.dart';
import 'package:depi1/features/prayer/domain/entities/prayer_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements PrayerLocalStorage {}

class _MockCalculator extends Mock implements PrayerTimeCalculator {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  late _MockStorage storage;
  late _MockCalculator calculator;
  late _MockLocationService locationService;
  late PrayerRepositoryImpl repository;

  const cairo = Coordinates(30.0444, 31.2357);
  final date = DateTime(2026, 9, 1);

  List<PrayerModel> dayOfPrayers() => [
        PrayerModel(name: PrayerName.fajr, time: DateTime(2026, 9, 1, 4, 30)),
        PrayerModel(name: PrayerName.dhuhr, time: DateTime(2026, 9, 1, 12)),
        PrayerModel(name: PrayerName.asr, time: DateTime(2026, 9, 1, 15, 30)),
        PrayerModel(name: PrayerName.maghrib, time: DateTime(2026, 9, 1, 18, 30)),
        PrayerModel(name: PrayerName.isha, time: DateTime(2026, 9, 1, 20)),
      ];

  List<PrayerRecord> dayOfRecords({String? fajrStatus}) => [
        for (final prayer in dayOfPrayers())
          PrayerRecord(
            dateKey: '2026-09-01',
            prayerId: prayer.name.id,
            timeIso: prayer.time.toIso8601String(),
            statusId: prayer.name == PrayerName.fajr ? fajrStatus : null,
          ),
      ];

  setUpAll(() {
    registerFallbackValue(<PrayerRecord>[]);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const Coordinates(0, 0));
  });

  setUp(() {
    storage = _MockStorage();
    calculator = _MockCalculator();
    locationService = _MockLocationService();
    repository = PrayerRepositoryImpl(
      storage: storage,
      calculator: calculator,
      locationService: locationService,
    );

    when(() => locationService.getCoordinates(
        forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => cairo);
    when(() => storage.saveAll(any())).thenAnswer((_) async {});
  });

  group('getPrayersForDate', () {
    test('returns stored prayers without recomputing them', () async {
      when(() => storage.getByDate('2026-09-01')).thenReturn(dayOfRecords());

      final result = await repository.getPrayersForDate(date);

      final prayers = result.getOrElse(() => []);
      expect(prayers, hasLength(5));
      expect(prayers.first.name, PrayerName.fajr);
      verifyNever(() => calculator.calculate(
            date: any(named: 'date'),
            coordinates: any(named: 'coordinates'),
          ));
    });

    test('computes and persists an unseeded day, then reads it back', () async {
      var seeded = false;
      when(() => storage.getByDate('2026-09-01'))
          .thenAnswer((_) => seeded ? dayOfRecords() : <PrayerRecord>[]);
      when(() => calculator.calculate(
            date: any(named: 'date'),
            coordinates: any(named: 'coordinates'),
          )).thenReturn(dayOfPrayers());
      when(() => storage.saveAll(any())).thenAnswer((_) async {
        seeded = true;
      });

      final result = await repository.getPrayersForDate(date);

      expect(result.getOrElse(() => []), hasLength(5));
      verify(() => storage.saveAll(any())).called(1);
    });

    test('returns prayers in chronological order', () async {
      when(() => storage.getByDate('2026-09-01'))
          .thenReturn(dayOfRecords().reversed.toList());

      final prayers = (await repository.getPrayersForDate(date))
          .getOrElse(() => []);

      expect(
        prayers.map((p) => p.name),
        [
          PrayerName.fajr,
          PrayerName.dhuhr,
          PrayerName.asr,
          PrayerName.maghrib,
          PrayerName.isha,
        ],
      );
    });

    test('carries a recorded status through to the entity', () async {
      when(() => storage.getByDate('2026-09-01'))
          .thenReturn(dayOfRecords(fajrStatus: 'congregation'));

      final prayers = (await repository.getPrayersForDate(date))
          .getOrElse(() => []);

      expect(prayers.first.status, PrayerStatus.congregation);
    });

    test('skips a corrupt row instead of failing the whole day', () async {
      when(() => storage.getByDate('2026-09-01')).thenReturn([
        ...dayOfRecords(),
        const PrayerRecord(
          dateKey: '2026-09-01',
          prayerId: 'not_a_prayer',
          timeIso: 'not_a_date',
        ),
      ]);

      final prayers = (await repository.getPrayersForDate(date))
          .getOrElse(() => []);

      expect(prayers, hasLength(5));
    });

    test('maps a disabled location service to a LocationFailure', () async {
      when(() => storage.getByDate(any())).thenReturn(<PrayerRecord>[]);
      when(() => locationService.getCoordinates(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(const LocationDisabledException());

      final result = await repository.getPrayersForDate(date);

      expect(result, const Left<Failure, List<PrayerEntity>>(
        LocationFailure.serviceDisabled,
      ));
    });

    test('maps a permanent permission denial to its own failure', () async {
      when(() => storage.getByDate(any())).thenReturn(<PrayerRecord>[]);
      when(() => locationService.getCoordinates(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(const LocationDeniedException(isPermanent: true));

      final result = await repository.getPrayersForDate(date);

      expect(result, const Left<Failure, List<PrayerEntity>>(
        LocationFailure.permissionDeniedForever,
      ));
    });

    test('maps a storage error to a CacheFailure', () async {
      when(() => storage.getByDate(any()))
          .thenThrow(const CacheException('box closed'));

      final result = await repository.getPrayersForDate(date);

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('right'));
    });

    test('fails cleanly when nothing usable can be read', () async {
      var attempts = 0;
      when(() => storage.getByDate(any())).thenAnswer((_) {
        attempts++;
        return <PrayerRecord>[];
      });
      when(() => calculator.calculate(
            date: any(named: 'date'),
            coordinates: any(named: 'coordinates'),
          )).thenReturn(<PrayerModel>[]);

      final result = await repository.getPrayersForDate(date);

      expect(attempts, 2);
      result.fold(
        (f) => expect(f, isA<PrayerCalculationFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('updateStatus', () {
    test('persists the status and returns the updated prayer', () async {
      when(() => storage.updateStatus(
            dateKey: any(named: 'dateKey'),
            prayerId: any(named: 'prayerId'),
            statusId: any(named: 'statusId'),
          )).thenAnswer((_) async => const PrayerRecord(
            dateKey: '2026-09-01',
            prayerId: 'fajr',
            timeIso: '2026-09-01T04:30:00.000',
            statusId: 'late',
          ));

      final result = await repository.updateStatus(
        date: date,
        prayer: PrayerModel(
          name: PrayerName.fajr,
          time: DateTime(2026, 9, 1, 4, 30),
        ),
        status: PrayerStatus.late,
      );

      expect(result.getOrElse(() => throw 'left').status, PrayerStatus.late);
      verify(() => storage.updateStatus(
            dateKey: '2026-09-01',
            prayerId: 'fajr',
            statusId: 'late',
          )).called(1);
    });

    test('fails when the prayer is not in storage', () async {
      when(() => storage.updateStatus(
            dateKey: any(named: 'dateKey'),
            prayerId: any(named: 'prayerId'),
            statusId: any(named: 'statusId'),
          )).thenAnswer((_) async => null);

      final result = await repository.updateStatus(
        date: date,
        prayer: PrayerModel(name: PrayerName.fajr, time: DateTime(2026, 9, 1)),
        status: PrayerStatus.late,
      );

      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('right'));
    });
  });

  group('seedPrayerTimes', () {
    test('computes only the days that are missing, in one batched write',
        () async {
      // Every day already present except one: the calculator should run once.
      when(() => storage.getByDate(any())).thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        return key == '2026-09-01' ? <PrayerRecord>[] : dayOfRecords();
      });
      when(() => calculator.calculate(
            date: any(named: 'date'),
            coordinates: any(named: 'coordinates'),
          )).thenReturn(dayOfPrayers());

      final result = await repository.seedPrayerTimes();

      expect(result.isRight(), isTrue);
      verify(() => calculator.calculate(
            date: any(named: 'date'),
            coordinates: any(named: 'coordinates'),
          )).called(1);
      verify(() => storage.saveAll(any())).called(1);
    });

    test('returns a failure when the location cannot be resolved', () async {
      when(() => storage.getByDate(any())).thenReturn(<PrayerRecord>[]);
      when(() => locationService.getCoordinates(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(const LocationDeniedException());

      final result = await repository.seedPrayerTimes();

      expect(result, const Left<Failure, Unit>(LocationFailure.permissionDenied));
      verifyNever(() => storage.saveAll(any()));
    });
  });
}
