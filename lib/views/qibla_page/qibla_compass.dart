// import 'dart:async';
// import 'package:depi1/resources/image_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math' show pi;
//
// class QiblaCompass extends StatefulWidget {
//   const QiblaCompass({super.key});
//
//   @override
//   State<QiblaCompass> createState() => _QiblaCompassState();
// }
//
// class _QiblaCompassState extends State<QiblaCompass> {
//   final _locationStreamController = StreamController<LocationStatus>.broadcast();
//
//   get stream => _locationStreamController.stream;
//
//   Future<void> _checkLocationStatus() async {
//     final locationStatus = await FlutterQiblah.checkLocationStatus();
//     if (locationStatus.enabled &&
//         locationStatus.status == LocationPermission.denied) {
//       await FlutterQiblah.requestPermissions();
//       final s = await FlutterQiblah.checkLocationStatus();
//       _locationStreamController.sink.add(s);
//     } else {
//       _locationStreamController.sink.add(locationStatus);
//     }
//   }
//
//   @override
//   void initState() {
//     _checkLocationStatus();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _locationStreamController.close();
//     FlutterQiblah().dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       padding: EdgeInsets.all(8.00.w.h),
//       child: StreamBuilder(
//         stream: stream,
//         builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (snapshot.data!.enabled) {
//             switch (snapshot.data!.status) {
//               case LocationPermission.always:
//               case LocationPermission.whileInUse:
//                 return QiblaCompassWidget();
//               case LocationPermission.denied:
//               case LocationPermission.deniedForever:
//                 return LocationErrorWidget(
//                   error: "Please enable Location Service",
//                   callback: _checkLocationStatus,
//                 );
//               default:
//                 return Container();
//             }
//           } else {
//             return LocationErrorWidget(error: "Please enable Location Service");
//           }
//         },
//       ),
//     );
//   }
// }
//
// class QiblaCompassWidget extends StatelessWidget {
//   final _compassImage = SvgPicture.asset(ImageManger.qiblaImage0);
//   final _needleImage = SvgPicture.asset(
//     ImageManger.directionQibla,
//     fit: BoxFit.contain,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final compassSize = size.width * 0.8; // 80% of the screen width
//
//     return StreamBuilder(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         final qiblaDirection = snapshot.data;
//         return SizedBox(
//           width: compassSize,
//           height: compassSize,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Transform.rotate(
//                 angle: (qiblaDirection!.qiblah * (pi / 180) * -1),
//                 child: _compassImage,
//               ),
//               Transform.rotate(
//                 angle: (qiblaDirection.qiblah * (pi / 180) * -1),
//                 alignment: Alignment.center,
//                 child: _needleImage,
//               ),
//               Positioned(
//                 child: Text("${qiblaDirection.offset.toStringAsFixed(3)}"),
//                 bottom: 8,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class LocationErrorWidget extends StatelessWidget {
//   final String error;
//   final Function? callback;
//   const LocationErrorWidget({super.key, required this.error, this.callback});
//
//   @override
//   Widget build(BuildContext context) {
//     const errorColor = Color(0xffb00020);
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.location_off,
//             size: 150,
//             color: errorColor,
//           ),
//           const SizedBox(height: 32),
//           Text(
//             error,
//             style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 32),
//           ElevatedButton(
//             onPressed: () {
//               if (callback != null) {
//                 callback!();
//               }
//             },
//             child: Text("Retry Again"),
//           ),
//         ],
//       ),
//     );
//   }
// }


///
/*
import 'package:depi1/resources/text_style.dart';
import 'package:depi1/views/qibla_page/qibla_compass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QiblahPage extends StatelessWidget {
  QiblahPage({super.key});

  final Future<bool?> _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [

            FutureBuilder<bool?>(
              future: _deviceSupport,
              builder: (_, AsyncSnapshot<bool?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return const QiblaCompass();
                } else {
                  return const Center(
                    child: Text("Your device is not supported"),
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}
 */