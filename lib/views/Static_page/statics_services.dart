import 'dart:async';

import '../../sql/sql_db.dart';


class StatisticsService {
  final SqlDb _sqlDb = SqlDb();
  static const double miniBarValue = 10;
  static const double maxBarValue = 60;
  static const double pixelsPerRecord = 3; // كل تسجيل يزيد الـ bar بـ 3 بكسل
  static const int weeklyPrayersTotal = 35; // إجمالي الصلوات في الأسبوع

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
    // تحديد النطاق الزمني (اليوم الحالي إلى آخر 6 أيام)
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));

    // الحالات المعرفة (باستثناء "لم أصلي")
    const prayedStatuses = ["منفردا", "متأخر", "جماعه"];
    int totalPrayed = 0;

    for (String status in prayedStatuses) {
      totalPrayed += await _sqlDb.getStatusCountInRange(status, startDate, endDate);
    }

    // النسبة المئوية بناءً على إجمالي الصلوات في الأسبوع (35)
    String percentage = weeklyPrayersTotal > 0 ? "${((totalPrayed / weeklyPrayersTotal) * 100).toStringAsFixed(0)}%" : "0%";

    return {
      "percentage": percentage,
      "totalPrayed": totalPrayed,
      "message": totalPrayed < weeklyPrayersTotal ? "واصل السعي لتحقيق الأفضل!" : "مبروك! أديت كل الصلوات!",
    };
  }

  Future<Map<String, Map<String, dynamic>>> _calculateStatistics() async {
    // الحالات التي نريد إحصائياتها
    const statuses = ["لم اصلي", "منفردا", "متأخر", "جماعه"];
    const prayerNames = ["الفجر", "الظهر", "العصر", "المغرب", "العشاء"];

    // إجمالي عدد تسجيلات الحالات المعرفة فقط
    int totalPrayers = 0;
    for (String status in statuses) {
      totalPrayers += await _sqlDb.getStatusCount(status);
    }

    Map<String, Map<String, dynamic>> stats = {};

    for (String status in statuses) {
      // عدد التسجيلات لهذه الحالة
      int statusCount = await _sqlDb.getStatusCount(status);
      // النسبة المئوية بناءً على إجمالي الحالات المعرفة
      String percentage = totalPrayers > 0 ? "${((statusCount / totalPrayers) * 100).toStringAsFixed(0)}%" : "0%";
      // عدد المرات
      String count = "$statusCount مره";

      // إحصائيات الـ bars لكل صلاة
      double fajrBar = miniBarValue;
      double dhurBar = miniBarValue;
      double asrBar = miniBarValue;
      double maghribBar = miniBarValue;
      double ishaBar = miniBarValue;

      for (String prayerName in prayerNames) {
        int prayerCount = await _sqlDb.getPrayerCountByStatus(prayerName, status);
        // كل تسجيل يزيد الـ bar بـ 3 بكسل، مع ضمان الحد الأدنى والأقصى
        double barValue = prayerCount > 0 ? (prayerCount * pixelsPerRecord).clamp(miniBarValue, maxBarValue) : miniBarValue;

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