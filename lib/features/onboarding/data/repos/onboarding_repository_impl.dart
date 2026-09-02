import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repos/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SharedPreferences _prefs;

  const OnboardingRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, bool>> hasSeenOnboarding() async {
    try {
      // The stored flag is "is first time", inverted here so the domain reads
      // in the positive. The key is kept as-is so existing installs are not
      // shown the intro again after upgrading.
      final isFirstTime =
          _prefs.getBool(AppConstants.prefOnboardingSeen) ?? true;
      return Right(!isFirstTime);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOnboardingSeen() async {
    try {
      await _prefs.setBool(AppConstants.prefOnboardingSeen, false);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }
}
