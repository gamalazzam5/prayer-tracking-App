import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    prayerItem = await PrayerService.loadPrayerTimes();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.only(top: 64.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : prayerItem.isNotEmpty
              ? Column(
            children: [
              CardWidget(prayerItem: prayerItem),
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