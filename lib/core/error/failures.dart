import 'package:equatable/equatable.dart';

/// Typed failures crossing the data → domain → presentation boundary.
///
/// The data layer catches raw exceptions and maps them to one of these; the
/// presentation layer maps them to user-facing messages.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Reading from / writing to local storage failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'تعذر الوصول إلى البيانات المحفوظة']);
}

/// The device location could not be resolved (services off, permission denied…).
class LocationFailure extends Failure {
  const LocationFailure([super.message = 'تعذر تحديد موقعك']);

  /// Location services are switched off at the OS level.
  static const LocationFailure serviceDisabled =
      LocationFailure('خدمة تحديد الموقع غير مفعّلة، من فضلك قم بتفعيلها');

  /// The user declined the permission for now.
  static const LocationFailure permissionDenied =
      LocationFailure('تم رفض إذن الوصول إلى الموقع');

  /// The user declined permanently; only the app settings can restore it.
  static const LocationFailure permissionDeniedForever = LocationFailure(
    'تم رفض إذن الموقع نهائياً، فعّله من إعدادات التطبيق',
  );
}

/// The device has no usable compass / magnetometer.
class CompassUnavailableFailure extends Failure {
  const CompassUnavailableFailure([
    super.message = 'جهازك لا يحتوي على بوصلة تدعم تحديد القبلة',
  ]);
}

/// Prayer times could not be computed for the requested date.
class PrayerCalculationFailure extends Failure {
  const PrayerCalculationFailure([
    super.message = 'تعذر حساب مواقيت الصلاة',
  ]);
}

/// Anything we did not anticipate.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'حدث خطأ غير متوقع']);
}
