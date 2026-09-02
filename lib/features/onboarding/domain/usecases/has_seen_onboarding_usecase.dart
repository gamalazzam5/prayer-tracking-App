import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repos/onboarding_repository.dart';

class HasSeenOnboardingUseCase {
  final OnboardingRepository _repository;

  const HasSeenOnboardingUseCase(this._repository);

  Future<Either<Failure, bool>> call() => _repository.hasSeenOnboarding();
}
