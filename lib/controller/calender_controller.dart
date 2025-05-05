
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DateController extends GetxController {
  var selectedDate = DateTime.now().obs;

  void changeDate(int daysToAdd) {
    final newDate = selectedDate.value.add(Duration(days: daysToAdd));
    final today = DateTime.now();

    // Check if the new date is greater than today
    if (newDate.isAfter(today) && daysToAdd > 0) {
      // Do not update the date if trying to go beyond today
      return;
    }

    selectedDate.value = newDate;
    update(); // Notify listeners to rebuild UI
  }

  bool canIncrementDate() {
    final newDate = selectedDate.value.add(Duration(days: 1));
    final today = DateTime.now();
    return !newDate.isAfter(today);
  }

  String get formattedDate {
    final date = selectedDate.value;
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthName(date.month);
    final year = date.year.toString();
    return "$day $month $year";
  }

  String get formattedDateForDb {
    final date = selectedDate.value;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    const monthNames = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return monthNames[month - 1];
  }
}