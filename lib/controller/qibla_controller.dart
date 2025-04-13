import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class QiblaController extends GetxController {
  var direction = 0.0.obs; // Device compass direction
  var qiblaDirection = 0.0.obs; // Qibla angle

  @override
  void onInit() {
    super.onInit();
    _getUserLocation();
    _listenToCompass();
  }

  void _listenToCompass() {
    FlutterCompass.events!.listen((event) {
      direction.value = event.heading ?? 0.0;
    });
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    qiblaDirection.value = _calculateQiblaDirection(position.latitude, position.longitude);
  }

  double _calculateQiblaDirection(double lat, double lon) {
    double kaabaLat = 21.4225;
    double kaabaLon = 39.8262;
    double deltaLon = (kaabaLon - lon).toRadians();
    double latRad = lat.toRadians();
    double kaabaLatRad = kaabaLat.toRadians();

    double y = sin(deltaLon) * cos(kaabaLatRad);
    double x = cos(latRad) * sin(kaabaLatRad) - sin(latRad) * cos(kaabaLatRad) * cos(deltaLon);
    double qiblaAngle = atan2(y, x).toDegrees();

    return (qiblaAngle + 360) % 360;
  }
}

extension DoubleExtensions on double {
  double toRadians() => this * pi / 180;
  double toDegrees() => this * 180 / pi;
}
