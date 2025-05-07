import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/prayers_model.dart';
import '../../resources/image_manager.dart';
import '../sql/sql_db.dart';


class PrayerService {
  static final SqlDb _sqlDb = SqlDb();
  static final Map<String, List<PrayerModel>> _cachedPrayers = {};

  /// Initialize prayer times for the last 30 days and next 30 days
  static Future<void> initializePrayerTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

   ///get current location if it doesn't existed
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');
    if (latitude == null || longitude == null) {
      Position position = await _getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      prefs.setDouble('latitude', latitude);
      prefs.setDouble('longitude', longitude);
    }

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.egyptian();

//calculate and store prayer time before 30 days and after 30 days
    for (int i = -30; i <= 30; i++) {
      DateTime date = now.add(Duration(days: i));
      String formattedDate = _formatDate(date);

      //check if the information is existing or not
      var existing = await _sqlDb.getPrayersByDate(formattedDate);
      if (existing.isNotEmpty) continue;// here skip if the information is existed

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true,
      );

      List<PrayerModel> prayers = [
        PrayerModel(
          time: prayerTimes.fajr!.toLocal(),
          prayerNameAr: "الفجر",
          prayerNameEN: "Fajr",
          iconWeatherUrl: ImageManger.fajrIcon,
          amOrPm: prayerTimes.fajr!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.fajrIcon,
          status: null,
          iconStatusUrl: null,
        ),
        PrayerModel(
          time: prayerTimes.dhuhr!.toLocal(),
          prayerNameAr: "الظهر",
          prayerNameEN: "Dhuhr",
          iconWeatherUrl: ImageManger.duhurIcon,
          amOrPm: prayerTimes.dhuhr!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.duhurIcon,
          status: null,
          iconStatusUrl: null,
        ),
        PrayerModel(
          time: prayerTimes.asr!.toLocal(),
          prayerNameAr: "العصر",
          prayerNameEN: "Asr",
          iconWeatherUrl: ImageManger.shurukAndAsrIcon,
          amOrPm: prayerTimes.asr!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.shurukAndAsrIcon,
          status: null,
          iconStatusUrl: null,
        ),
        PrayerModel(
          time: prayerTimes.maghrib!.toLocal(),
          prayerNameAr: "المغرب",
          prayerNameEN: "Maghrib",
          iconWeatherUrl: ImageManger.maghribIcon,
          amOrPm: prayerTimes.maghrib!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.maghribIcon,
          status: null,
          iconStatusUrl: null,
        ),
        PrayerModel(
          time: prayerTimes.isha!.toLocal(),
          prayerNameAr: "العشاء",
          prayerNameEN: "Isha",
          iconWeatherUrl: ImageManger.ishaIcon,
          amOrPm: prayerTimes.isha!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.ishaIcon,
          status: null,
          iconStatusUrl: null,
        ),
      ];

     ///store data in the sqflite
      for (var prayer in prayers) {
        await _sqlDb.insertPrayer(
          formattedDate,
          prayer.prayerNameAr,
          prayer.time.toIso8601String(),
          prayer.status,
          prayer.iconStatusUrl,
        );
      }
    }
  }

  /// Loads prayer times from the database
  static Future<List<PrayerModel>> loadPrayerTimes({DateTime? date}) async {
    DateTime now = date ?? DateTime.now();
    String formattedDate = _formatDate(now);

    ///check if the data in the cache or not
    if (_cachedPrayers.containsKey(formattedDate)) {
      return _cachedPrayers[formattedDate]!;
    }

   ///get data from Database
    var dbPrayers = await _sqlDb.getPrayersByDate(formattedDate);
    if (dbPrayers.isEmpty) {
      ///if the it doesn't existed create it
      await _fetchPrayerTimes(date: now);
      dbPrayers = await _sqlDb.getPrayersByDate(formattedDate);
    }

    List<PrayerModel> prayers = dbPrayers.map((dbPrayer) {
      return PrayerModel(
        time: DateTime.parse(dbPrayer['prayerTime']),
        prayerNameAr: dbPrayer['prayerName'],
        prayerNameEN: _getEnglishName(dbPrayer['prayerName']),
        iconWeatherUrl: _getIconUrl(dbPrayer['prayerName']),
        amOrPm: DateTime.parse(dbPrayer['prayerTime']).hour >= 12 ? ' PM' : ' AM',
        prayerIcon: _getIconUrl(dbPrayer['prayerName']),
        status: dbPrayer['status'],
        iconStatusUrl: dbPrayer['statusIconUrl'],
      );
    }).toList();

    _cachedPrayers[formattedDate] = prayers;
    return prayers;
  }

  static Future<List<PrayerModel>> _fetchPrayerTimes({required DateTime date}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');

    if (latitude == null || longitude == null) {
      Position position = await _getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      prefs.setDouble('latitude', latitude);
      prefs.setDouble('longitude', longitude);
    }

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.egyptian();
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    List<PrayerModel> prayers = [
      PrayerModel(
        time: prayerTimes.fajr!.toLocal(),
        prayerNameAr: "الفجر",
        prayerNameEN: "Fajr",
        iconWeatherUrl: ImageManger.fajrIcon,
        amOrPm: prayerTimes.fajr!.hour >= 12 ? ' PM' : ' AM',
        prayerIcon: ImageManger.fajrIcon,
        status: null,
        iconStatusUrl: null,
      ),
      PrayerModel(
        time: prayerTimes.dhuhr!.toLocal(),
        prayerNameAr: "الظهر",
        prayerNameEN: "Dhuhr",
        iconWeatherUrl: ImageManger.duhurIcon,
        amOrPm: prayerTimes.dhuhr!.hour >= 12 ? ' PM' : ' AM',
        prayerIcon: ImageManger.duhurIcon,
        status: null,
        iconStatusUrl: null,
      ),
      PrayerModel(
        time: prayerTimes.asr!.toLocal(),
        prayerNameAr: "العصر",
        prayerNameEN: "Asr",
        iconWeatherUrl: ImageManger.shurukAndAsrIcon,
        amOrPm: prayerTimes.asr!.hour >= 12 ? ' PM' : ' AM',
        prayerIcon: ImageManger.shurukAndAsrIcon,
        status: null,
        iconStatusUrl: null,
      ),
      PrayerModel(
        time: prayerTimes.maghrib!.toLocal(),
        prayerNameAr: "المغرب",
        prayerNameEN: "Maghrib",
        iconWeatherUrl: ImageManger.maghribIcon,
        amOrPm: prayerTimes.maghrib!.hour >= 12 ? ' PM' : ' AM',
        prayerIcon: ImageManger.maghribIcon,
        status: null,
        iconStatusUrl: null,
      ),
      PrayerModel(
        time: prayerTimes.isha!.toLocal(),
        prayerNameAr: "العشاء",
        prayerNameEN: "Isha",
        iconWeatherUrl: ImageManger.ishaIcon,
        amOrPm: prayerTimes.isha!.hour >= 12 ? ' PM' : ' AM',
        prayerIcon: ImageManger.ishaIcon,
        status: null,
        iconStatusUrl: null,
      ),
    ];

    String formattedDate = _formatDate(date);
    for (var prayer in prayers) {
      await _sqlDb.insertPrayer(
        formattedDate,
        prayer.prayerNameAr,
        prayer.time.toIso8601String(),
        prayer.status,
        prayer.iconStatusUrl,
      );
    }

    return prayers;
  }

  static Future<void> updatePrayerStatus(String date, String prayerName, String? status, String? statusIconUrl) async {
    await _sqlDb.updatePrayerStatus(date, prayerName, status, statusIconUrl);
   /// update the date if it available
    if (_cachedPrayers.containsKey(date)) {
      var prayers = _cachedPrayers[date]!;
      var prayer = prayers.firstWhere((p) => p.prayerNameAr == prayerName);
      prayer.status = status;
      prayer.iconStatusUrl = statusIconUrl;
    }
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static String _getEnglishName(String prayerNameAr) {
    switch (prayerNameAr) {
      case "الفجر":
        return "Fajr";
      case "الظهر":
        return "Dhuhr";
      case "العصر":
        return "Asr";
      case "المغرب":
        return "Maghrib";
      case "العشاء":
        return "Isha";
      default:
        return "";
    }
  }

  static String _getIconUrl(String prayerNameAr) {
    switch (prayerNameAr) {
      case "الفجر":
        return ImageManger.fajrIcon;
      case "الظهر":
        return ImageManger.duhurIcon;
      case "العصر":
        return ImageManger.shurukAndAsrIcon;
      case "المغرب":
        return ImageManger.maghribIcon;
      case "العشاء":
        return ImageManger.ishaIcon;
      default:
        return "";
    }
  }

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}