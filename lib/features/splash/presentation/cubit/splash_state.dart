import 'package:equatable/equatable.dart';

/// Where the splash screen should send the user once start-up finishes.
enum SplashDestination { onboarding, home }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashReady extends SplashState {
  final SplashDestination destination;

  const SplashReady(this.destination);

  @override
  List<Object?> get props => [destination];
}
