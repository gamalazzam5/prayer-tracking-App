import '../repos/statistics_repository.dart';

class WatchStatisticsChangesUseCase {
  final StatisticsRepository _repository;

  const WatchStatisticsChangesUseCase(this._repository);

  Stream<void> call() => _repository.watchChanges();
}
