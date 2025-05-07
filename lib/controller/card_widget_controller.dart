import 'dart:async';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:depi1/models/prayers_model.dart';
import 'package:depi1/services/prayer_service.dart';

class CardWidgetController extends GetxController {
  final todayPrayerItem = RxList<PrayerModel>([]);
  late Timer _timer;
  var timeRemaining = '00:00:00'.obs;
  var hijriDate = ''.obs;
  var nextPrayerIndex = 0.obs;
  late DateTime _lastCheckedDate;

  CardWidgetController();

  @override
  void onInit() async {
    super.onInit();
    _lastCheckedDate = DateTime.now();
    hijriDate.value = _getHijriDate();
    await _loadTodayPrayers();
    nextPrayerIndex.value = _getNextPrayerIndex();
    _startTimer();
  }

  Future<void> _loadTodayPrayers() async {
    todayPrayerItem.value = await PrayerService.loadPrayerTimes(date: DateTime.now());
    if (todayPrayerItem.isEmpty) {

      print("Error: Failed to load prayer times");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeRemaining.value = _calculateTimeRemaining();

      if (DateTime.now().isAfter(todayPrayerItem[nextPrayerIndex.value].time)) {
        nextPrayerIndex.value = _getNextPrayerIndex();
      }

      if (_isNewDay()) {
        hijriDate.value = _getHijriDate();
        _lastCheckedDate = DateTime.now();
        _loadTodayPrayers();
      }
    });
  }

  bool _isNewDay() => DateTime.now().day != _lastCheckedDate.day;

  int _getNextPrayerIndex() {
    DateTime now = DateTime.now();
    for (int i = 0; i < todayPrayerItem.length; i++) {
      if (todayPrayerItem[i].time.isAfter(now)) return i;
    }
    return 0;
  }

  String _calculateTimeRemaining() {
    DateTime now = DateTime.now();
    DateTime nextPrayerTime = todayPrayerItem[nextPrayerIndex.value].time;

    if (nextPrayerIndex.value == todayPrayerItem.length - 1 &&
        now.isAfter(nextPrayerTime)) {
      nextPrayerTime = todayPrayerItem[0].time.add(const Duration(days: 1));
    }

    if (nextPrayerTime.isBefore(now)) {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }

    final duration = nextPrayerTime.difference(now);
    return "${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  String _getHijriDate() {
    final hijri = HijriCalendar.now();
    const months = [
      "محرم",
      "صفر",
      "ربيع الأول",
      "ربيع الآخر",
      "جمادى الأولى",
      "جمادى الآخرة",
      "رجب",
      "شعبان",
      "رمضان",
      "شوال",
      "ذو القعدة",
      "ذو الحجة"
    ];
    return "${hijri.hDay} ${months[hijri.hMonth - 1]} ${hijri.hYear} هـ";
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}