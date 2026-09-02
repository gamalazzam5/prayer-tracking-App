import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repos/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  const CompleteOnboardingUseCase(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.markOnboardingSeen();
}
