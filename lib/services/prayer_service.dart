import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/prayers_model.dart';
import '../../resources/image_manager.dart';

class PrayerService {
  /// Loads prayer times for the current day.
  /// It first checks if prayer times are already cached for today.
  /// If not, it fetches new prayer times based on the cached or current location.
  static Future<List<PrayerModel>> loadPrayerTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDate = prefs.getString('prayerDate');
    DateTime now = DateTime.now();

    // If there is no stored date or it is not for today, fetch new prayer times
    if (storedDate == null || DateTime.parse(storedDate).day != now.day) {
      return await _fetchPrayerTimes();
    } else {
      // Load cached prayer times
      return _getCachedPrayerTimes(prefs);
    }
  }

  /// Fetches prayer times based on the user's stored or current location.
  /// It retrieves the user's GPS coordinates only if not already cached.
  static Future<List<PrayerModel>> _fetchPrayerTimes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double? latitude = prefs.getDouble('latitude');
      double? longitude = prefs.getDouble('longitude');

      if (latitude == null || longitude == null) {
        // Get and store location for the first time
        Position position = await _getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
        prefs.setDouble('latitude', latitude);
        prefs.setDouble('longitude', longitude);
      }

      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.egyptian();
      final date = DateTime.now();

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
          status: '',
          iconStatusUrl: '',
        ),
        PrayerModel(
          time: prayerTimes.dhuhr!.toLocal(),
          prayerNameAr: "الظهر",
          prayerNameEN: "Dhuhr",
          iconWeatherUrl: ImageManger.duhurIcon,
          amOrPm: prayerTimes.dhuhr!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.duhurIcon,
          status: '',
          iconStatusUrl: '',
        ),
        PrayerModel(
          time: prayerTimes.asr!.toLocal(),
          prayerNameAr: "العصر",
          prayerNameEN: "Asr",
          iconWeatherUrl: ImageManger.shurukAndAsrIcon,
          amOrPm: prayerTimes.asr!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.shurukAndAsrIcon,
          status: '',
          iconStatusUrl: '',
        ),
        PrayerModel(
          time: prayerTimes.maghrib!.toLocal(),
          prayerNameAr: "المغرب",
          prayerNameEN: "Maghrib",
          iconWeatherUrl: ImageManger.maghribIcon,
          amOrPm: prayerTimes.maghrib!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.maghribIcon,
          status: '',
          iconStatusUrl: '',
        ),
        PrayerModel(
          time: prayerTimes.isha!.toLocal(),
          prayerNameAr: "العشاء",
          prayerNameEN: "Isha",
          iconWeatherUrl: ImageManger.ishaIcon,
          amOrPm: prayerTimes.isha!.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: ImageManger.ishaIcon,
          status: '',
          iconStatusUrl: '',
        ),
      ];

      // Store the prayer times in cache
      prefs.setString('prayerDate', date.toIso8601String());
      _cachePrayerTimes(prefs, prayers);

      return prayers;
    } catch (e) {
      print('Error fetching prayer times: $e');
      return [];
    }
  }

  /// Retrieves the current location of the user using the Geolocator package.
  /// It requests location permissions if they are not already granted.
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
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Caches the fetched prayer times in SharedPreferences for offline use.
  static void _cachePrayerTimes(SharedPreferences prefs, List<PrayerModel> prayers) {
    for (int i = 0; i < prayers.length; i++) {
      prefs.setString('prayerTime_$i', prayers[i].time.toIso8601String());
    }
  }

  /// Retrieves cached prayer times from SharedPreferences.
  static List<PrayerModel> _getCachedPrayerTimes(SharedPreferences prefs) {
    List<PrayerModel> cachedPrayers = [];
    for (int i = 0; i < 5; i++) {
      String? timeString = prefs.getString('prayerTime_$i');
      if (timeString != null) {
        DateTime time = DateTime.parse(timeString);
        cachedPrayers.add(PrayerModel(
          time: time,
          prayerNameAr: ["الفجر", "الظهر", "العصر", "المغرب", "العشاء"][i],
          prayerNameEN: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"][i],
          iconWeatherUrl: [
            ImageManger.fajrIcon,
            ImageManger.duhurIcon,
            ImageManger.shurukAndAsrIcon,
            ImageManger.maghribIcon,
            ImageManger.ishaIcon
          ][i],
          amOrPm: time.hour >= 12 ? ' PM' : ' AM',
          prayerIcon: [
            ImageManger.fajrIcon,
            ImageManger.duhurIcon,
            ImageManger.shurukAndAsrIcon,
            ImageManger.maghribIcon,
            ImageManger.ishaIcon
          ][i],
          status: '',
          iconStatusUrl: '',
        ));
      }
    }
    return cachedPrayers;
  }
}
