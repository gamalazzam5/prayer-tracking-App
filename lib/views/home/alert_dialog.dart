import 'package:depi1/views/home/prayerCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/alert_container.dart';
import '../../models/prayers_model.dart';
import '../../resources/image_manager.dart';
import '../../resources/text_style.dart';
import 'alert_container.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    super.key,
    required this.prayerItem,
    required this.widget,
    required this.onStatusChange,
  });

  final List<PrayerModel> prayerItem;
  final PrayerCategory widget;
  final Function(String, String) onStatusChange;

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<AlertContainer> items = [
      AlertContainer(
        text: "لم اصلي",
        image: ImageManger.slashIcon,
        isSelected: selectedIndex == 0,
        onTap: () {
          _updateStatus(0, "لم اصلي", ImageManger.slashIcon);
        },
      ),
      AlertContainer(
        text: "صليت متأخر",
        image: ImageManger.lateIcon,
        isSelected: selectedIndex == 1,
        onTap: () {
          _updateStatus(1, "متأخر", ImageManger.lateIcon);
        },
      ),
      AlertContainer(
        text: "صليت منفردا",
        image: ImageManger.aloneIcon,
        isSelected: selectedIndex == 2,
        onTap: () {
          _updateStatus(2, "منفردا", ImageManger.aloneIcon);
        },
      ),
      AlertContainer(
        text: "صليت في جماعه",
        image: ImageManger.gama3aIcon,
        isSelected: selectedIndex == 3,
        onTap: () {
          _updateStatus(3, "جماعه", ImageManger.gama3aIcon);
        },
      ),
    ];

    return SizedBox(
      width: 362.w,
      height: 356.h,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        backgroundColor: Color(0xffFFFFFF),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Image.asset(
                ImageManger.closeIcon,
                width: 24.w,
                height: 24.h,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 58.0.h),
              child: Text(
                "كيف صليت ${widget.prayerItem[widget.widget.index].prayerNameAr} اليوم ؟ ",
                style: TextStyles.prayerNameAr1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return Column(
              children: [
                AlertBuildContainer(
                  onTap: item.onTap,
                  isSelected: item.isSelected,
                  text: item.text,
                  image: item.image,
                ),
                SizedBox(height: 10.h),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _updateStatus(int index, String status, String icon) {
    setState(() {
      selectedIndex = index;
    });
    widget.onStatusChange(status, icon);
    Navigator.of(context).pop();
  }
}