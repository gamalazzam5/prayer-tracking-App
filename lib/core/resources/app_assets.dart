/// Asset paths. Keeping them in one place stops typo'd strings from reaching
/// the widget tree.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images/';
  static const String _icons = 'assets/images/icons/';
  static const String _prayerIcons = 'assets/images/icons/prayerIcons/';

  // Backgrounds & branding
  static const String pattern = '${_images}pattern.png';
  static const String splash = '${_images}splashScreen.png';
  static const String whiteMosque = '${_images}whiteMosque.png';
  static const String blackMosque = '${_images}blackMosque.png';

  // Onboarding
  static const String onboarding1 = '${_images}onboarding1.png';
  static const String onboarding2 = '${_images}onboarding2.png';
  static const String onboarding3 = '${_images}onboarding3.png';

  // Qibla
  static const String qiblaDial = '${_images}backgroundQibla.svg';
  static const String qiblaNeedle = '${_images}lastQibla.svg';

  // Statistics
  static const String analysisIcon = '${_images}analysis.png';
  static const String achievementCard = '${_images}cardAchivement.svg';

  // Bottom navigation
  static const String navHome = '${_icons}mosque.png';
  static const String navQibla = '${_icons}kaaba.png';
  static const String navStatistics = '${_icons}statics.png';

  // Prayer icons
  static const String fajrIcon = '${_prayerIcons}fajr.png';
  static const String dhuhrIcon = '${_prayerIcons}Duhur.png';
  static const String asrIcon = '${_prayerIcons}shurukAndAsr.png';
  static const String maghribIcon = '${_prayerIcons}Maghrib.png';
  static const String ishaIcon = '${_prayerIcons}isha.png';

  // Status icons
  static const String missedIcon = '${_prayerIcons}slash.svg';
  static const String lateIcon = '${_prayerIcons}clock.svg';
  static const String aloneIcon = '${_prayerIcons}alone.svg';
  static const String congregationIcon = '${_prayerIcons}gama3a.svg';
  static const String closeIcon = '${_prayerIcons}close_red.png';
}
