import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Only local wiring happens before `runApp`. Anything that can fail or block
  // — location, prayer-time seeding — runs behind the splash screen instead,
  // so a denied permission can no longer leave the user on a white screen.
  await initDependencies();

  runApp(const SalatyApp());
}
