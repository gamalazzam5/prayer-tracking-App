class PrayerModel {
   DateTime time;
  final String amOrPm;
   String status;
   String iconStatusUrl;
  final String prayerNameAr;
  final String prayerNameEN;
  final String prayerIcon;

  final String iconWeatherUrl;

  PrayerModel(
      {required this.amOrPm,
      required this.time,
      required this.status,
      required this.iconStatusUrl,
      required this.prayerNameAr,
      required this.prayerNameEN,
        required this.prayerIcon,
      required this.iconWeatherUrl});
}
