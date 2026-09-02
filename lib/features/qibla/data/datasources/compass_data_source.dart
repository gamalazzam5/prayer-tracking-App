import 'package:flutter_compass_v2/flutter_compass_v2.dart';

/// Device compass readings, in degrees clockwise from north.
abstract class CompassDataSource {
  /// Emits null when the device reports a reading it cannot resolve — the
  /// repository treats a stream that only ever yields null as "no compass".
  Stream<double?> get headings;
}

class FlutterCompassDataSource implements CompassDataSource {
  const FlutterCompassDataSource();

  @override
  Stream<double?> get headings {
    final events = FlutterCompass.events;
    if (events == null) return const Stream<double?>.empty();
    return events.map((event) => event.heading);
  }
}
