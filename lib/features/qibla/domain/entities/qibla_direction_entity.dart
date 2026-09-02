import 'package:equatable/equatable.dart';

/// A live qibla reading.
class QiblaDirectionEntity extends Equatable {
  /// Compass bearing to the Kaaba measured clockwise from true north, 0–360.
  /// Fixed for a given location.
  final double qiblaBearing;

  /// Where the top of the device is pointing, clockwise from north, 0–360.
  final double deviceHeading;

  const QiblaDirectionEntity({
    required this.qiblaBearing,
    required this.deviceHeading,
  });

  /// How far the needle must be rotated on screen: the qibla bearing relative
  /// to where the device is currently pointing, normalised to 0–360.
  double get offsetFromDevice {
    final offset = (qiblaBearing - deviceHeading) % 360;
    return offset < 0 ? offset + 360 : offset;
  }

  @override
  List<Object?> get props => [qiblaBearing, deviceHeading];
}
