import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/cubit/home_nav_cubit.dart';
import '../../features/onboarding/data/repos/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repos/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/has_seen_onboarding_usecase.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/prayer/data/datasources/prayer_time_calculator.dart';
import '../../features/prayer/data/repos/prayer_repository_impl.dart';
import '../../features/prayer/domain/repos/prayer_repository.dart';
import '../../features/prayer/domain/usecases/get_prayers_for_date_usecase.dart';
import '../../features/prayer/domain/usecases/resolve_next_prayer_usecase.dart';
import '../../features/prayer/domain/usecases/seed_prayer_times_usecase.dart';
import '../../features/prayer/domain/usecases/update_prayer_status_usecase.dart';
import '../../features/prayer/presentation/cubit/next_prayer_cubit.dart';
import '../../features/prayer/presentation/cubit/prayer_cubit.dart';
import '../../features/prayer/presentation/cubit/selected_date_cubit.dart';
import '../../features/qibla/data/datasources/compass_data_source.dart';
import '../../features/qibla/data/repos/qibla_repository_impl.dart';
import '../../features/qibla/domain/repos/qibla_repository.dart';
import '../../features/qibla/domain/services/qibla_bearing_calculator.dart';
import '../../features/qibla/domain/usecases/watch_qibla_direction_usecase.dart';
import '../../features/qibla/presentation/cubit/qibla_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/statistics/data/repos/statistics_repository_impl.dart';
import '../../features/statistics/domain/repos/statistics_repository.dart';
import '../../features/statistics/domain/usecases/get_statistics_usecase.dart';
import '../../features/statistics/domain/usecases/watch_statistics_changes_usecase.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';
import '../location/geolocator_location_service.dart';
import '../location/location_service.dart';
import '../storage/hive_prayer_local_storage.dart';
import '../storage/prayer_local_storage.dart';

/// Service locator. Every dependency is wired here — nothing is constructed
/// inline in a widget.
final GetIt sl = GetIt.instance;

/// Wires the object graph and opens local storage.
/// Must be awaited before `runApp`.
Future<void> initDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  await Hive.initFlutter();
  sl.registerLazySingleton<HiveInterface>(() => Hive);

  // --- Core services ---
  final storage = HivePrayerLocalStorage(hive: sl<HiveInterface>());
  await storage.init();
  sl.registerLazySingleton<PrayerLocalStorage>(() => storage);

  sl.registerLazySingleton<LocationService>(
    () => GeolocatorLocationService(prefs: sl<SharedPreferences>()),
  );

  _registerPrayerFeature();
  _registerQiblaFeature();
  _registerStatisticsFeature();
  _registerOnboardingFeature();

  // --- Shell & splash ---
  sl.registerFactory(() => HomeNavCubit());
  sl.registerFactory(
    () => SplashCubit(
      hasSeenOnboarding: sl<HasSeenOnboardingUseCase>(),
      seedPrayerTimes: sl<SeedPrayerTimesUseCase>(),
    ),
  );
}

void _registerPrayerFeature() {
  sl.registerLazySingleton<PrayerTimeCalculator>(
    () => const AdhanPrayerTimeCalculator(),
  );
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(
      storage: sl<PrayerLocalStorage>(),
      calculator: sl<PrayerTimeCalculator>(),
      locationService: sl<LocationService>(),
    ),
  );

  sl.registerLazySingleton(() => SeedPrayerTimesUseCase(sl<PrayerRepository>()));
  sl.registerLazySingleton(
    () => GetPrayersForDateUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdatePrayerStatusUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton(() => const ResolveNextPrayerUseCase());

  sl.registerFactory(() => SelectedDateCubit());
  sl.registerFactory(
    () => PrayerCubit(
      getPrayersForDate: sl<GetPrayersForDateUseCase>(),
      updatePrayerStatus: sl<UpdatePrayerStatusUseCase>(),
    ),
  );
  sl.registerFactory(
    () => NextPrayerCubit(
      getPrayersForDate: sl<GetPrayersForDateUseCase>(),
      resolveNextPrayer: sl<ResolveNextPrayerUseCase>(),
    ),
  );
}

void _registerQiblaFeature() {
  sl.registerLazySingleton<CompassDataSource>(
    () => const FlutterCompassDataSource(),
  );
  sl.registerLazySingleton(() => const QiblaBearingCalculator());
  sl.registerLazySingleton<QiblaRepository>(
    () => QiblaRepositoryImpl(
      compass: sl<CompassDataSource>(),
      locationService: sl<LocationService>(),
      calculateBearing: sl<QiblaBearingCalculator>(),
    ),
  );
  sl.registerLazySingleton(
    () => WatchQiblaDirectionUseCase(sl<QiblaRepository>()),
  );
  sl.registerFactory(
    () => QiblaCubit(watchQiblaDirection: sl<WatchQiblaDirectionUseCase>()),
  );
}

void _registerStatisticsFeature() {
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(storage: sl<PrayerLocalStorage>()),
  );
  sl.registerLazySingleton(
    () => GetStatisticsUseCase(sl<StatisticsRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchStatisticsChangesUseCase(sl<StatisticsRepository>()),
  );
  sl.registerFactory(
    () => StatisticsCubit(
      getStatistics: sl<GetStatisticsUseCase>(),
      watchChanges: sl<WatchStatisticsChangesUseCase>(),
    ),
  );
}

void _registerOnboardingFeature() {
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton(
    () => HasSeenOnboardingUseCase(sl<OnboardingRepository>()),
  );
  sl.registerLazySingleton(
    () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory(
    () => OnboardingCubit(completeOnboarding: sl<CompleteOnboardingUseCase>()),
  );
}
