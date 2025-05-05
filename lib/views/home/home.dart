import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/calender_controller.dart';
import '../../models/prayers_model.dart';
import '../../services/prayer_service.dart';
import 'calender.dart';
import 'card_widget.dart';
import 'list_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PrayerModel> prayerItem = [];
  final DateController dateController = Get.find<DateController>();

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    debounce(dateController.selectedDate, (_) => _loadPrayerTimes(),
        time: Duration(milliseconds: 300));
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    prayerItem = await PrayerService.loadPrayerTimes(date: dateController.selectedDate.value);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 64.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: prayerItem.isNotEmpty
            ? Column(
          children: [
            CardWidget(), // لا حاجة لتمرير prayerItem لأن CardWidget يعتمد على اليوم الحالي
            SizedBox(height: 16.h),
            Calendar(),
            SizedBox(height: 8.h),
            ListViewItems(prayerItem: prayerItem),
          ],
        )
            : Center(child: Text('Your app has a problem')),
      ),
    );
  }
}