import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The single loading indicator used across the app.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
}
