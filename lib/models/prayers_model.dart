class PrayerModel {
  DateTime time;
  String prayerNameAr;
  String prayerNameEN;
  String iconWeatherUrl;
  String amOrPm;
  String prayerIcon;
  String? status;
  String? iconStatusUrl;

  PrayerModel({
    required this.time,
    required this.prayerNameAr,
    required this.prayerNameEN,
    required this.iconWeatherUrl,
    required this.amOrPm,
    required this.prayerIcon,
    this.status,
    this.iconStatusUrl,
  });
}