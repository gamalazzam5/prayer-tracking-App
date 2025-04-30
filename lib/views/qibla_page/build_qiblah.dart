import 'package:depi1/views/qibla_page/qiblah_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_qiblah/flutter_qiblah.dart';

class BuildQiblah extends StatelessWidget {
  const BuildQiblah({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
    return FutureBuilder(
      future: deviceSupport,
      builder: (_, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error.toString()}"),
          );
        }
        if (snapshot.data!) {
          return QiblahCompass();
        } else {
          return const Center(
            child: Text("Your device is not supported"),
          );
        }
      },
    );
  }
}