/// App-wide constants shared by more than one feature.
class AppConstants {
  AppConstants._();

  /// Hive box holding one record per (date, prayer) pair.
  static const String prayersBoxName = 'prayers';

  /// SharedPreferences keys.
  static const String prefLatitude = 'latitude';
  static const String prefLongitude = 'longitude';
  static const String prefOnboardingSeen = 'isFirstTime';

  /// How many days around today are pre-seeded with prayer times.
  static const int seedDaysBefore = 30;
  static const int seedDaysAfter = 30;

  /// Splash hold time before routing away.
  static const Duration splashDuration = Duration(seconds: 2);

  /// Kaaba coordinates, used for the qibla bearing.
  static const double kaabaLatitude = 21.4224779;
  static const double kaabaLongitude = 39.8251832;
}
