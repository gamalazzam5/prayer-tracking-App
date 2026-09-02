import 'package:equatable/equatable.dart';

/// A geographic point. Pure Dart so the domain layer can depend on it.
class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}
