import 'package:equatable/equatable.dart';

/// One intro page.
class OnboardingPageEntity extends Equatable {
  final String imageAsset;
  final String title;
  final String subtitle;

  const OnboardingPageEntity({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [imageAsset, title, subtitle];
}
