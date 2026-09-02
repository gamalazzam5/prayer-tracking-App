import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class OnboardingRepository {
  /// True once the user has been through (or skipped) the intro pages.
  Future<Either<Failure, bool>> hasSeenOnboarding();

  /// Records that the intro no longer needs to be shown.
  Future<Either<Failure, Unit>> markOnboardingSeen();
}
