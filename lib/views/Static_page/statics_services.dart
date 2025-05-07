import 'dart:async';

import '../../sql/sql_db.dart';

class StatisticsService {
  final SqlDb _sqlDb = SqlDb();
  static const double miniBarValue = 10;
  static const double maxBarValue = 60;
  static const int weeklyPrayersTotal = 35;

  Stream<Map<String, dynamic>> getAchievementStream() async* {
    await for (var _ in _sqlDb.prayersStream) {
      yield await _calculateAchievement();
    }
  }

  Stream<Map<String, Map<String, dynamic>>> getStatisticsStream() async* {
    await for (var _ in _sqlDb.prayersStream) {
      yield await _calculateStatistics();
    }
  }

  Future<Map<String, dynamic>> _calculateAchievement() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));

    const prayedStatuses = ["منفردا", "متأخر", "جماعه"];
    int totalPrayed = 0;

    for (String status in prayedStatuses) {
      totalPrayed += await _sqlDb.getStatusCountInRange(status, startDate, endDate);
    }

    String percentage = weeklyPrayersTotal > 0 ? "${((totalPrayed / weeklyPrayersTotal) * 100).toStringAsFixed(0)}%" : "0%";

    return {
      "percentage": percentage,
      "totalPrayed": totalPrayed,
      "message": totalPrayed < weeklyPrayersTotal ? "واصل السعي لتحقيق الأفضل!" : "مبروك! أديت كل الصلوات!",
    };
  }

  Future<Map<String, Map<String, dynamic>>> _calculateStatistics() async {
    const statuses = ["لم اصلي", "منفردا", "متأخر", "جماعه"];
    const prayerNames = ["الفجر", "الظهر", "العصر", "المغرب", "العشاء"];

    int totalPrayers = 0;
    for (String status in statuses) {
      totalPrayers += await _sqlDb.getStatusCount(status);
    }

    Map<String, Map<String, dynamic>> stats = {};

    for (String status in statuses) {
      int statusCount = await _sqlDb.getStatusCount(status);
      String percentage = totalPrayers > 0 ? "${((statusCount / totalPrayers) * 100).toStringAsFixed(0)}%" : "0%";
      String count = "$statusCount مره";


      Map<String, int> prayerCounts = {};
      int totalCountsForStatus = 0;

      for (String prayerName in prayerNames) {
        int prayerCount = await _sqlDb.getPrayerCountByStatus(prayerName, status);
        prayerCounts[prayerName] = prayerCount;
        totalCountsForStatus += prayerCount;
      }

      double fajrBar = miniBarValue;
      double dhurBar = miniBarValue;
      double asrBar = miniBarValue;
      double maghribBar = miniBarValue;
      double ishaBar = miniBarValue;

      if (totalCountsForStatus > 0) {
        for (String prayerName in prayerNames) {
          double ratio = prayerCounts[prayerName]! / totalCountsForStatus;
          double barValue = maxBarValue * ratio;


          barValue = barValue < miniBarValue ? miniBarValue : barValue;

          switch (prayerName) {
            case "الفجر":
              fajrBar = barValue;
              break;
            case "الظهر":
              dhurBar = barValue;
              break;
            case "العصر":
              asrBar = barValue;
              break;
            case "المغرب":
              maghribBar = barValue;
              break;
            case "العشاء":
              ishaBar = barValue;
              break;
          }
        }
      }

      stats[status] = {
        "fajrBar": fajrBar,
        "dhurBar": dhurBar,
        "asrBar": asrBar,
        "maghribBar": maghribBar,
        "ishaBar": ishaBar,
        "percentage": percentage,
        "count": count,
      };
    }

    return stats;
  }
}