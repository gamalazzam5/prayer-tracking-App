import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Right-aligned RTL heading used by the statistics screen sections.
class SectionTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const SectionTitle(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          style: style ?? AppTextStyles.screenTitle,
        ),
      );
}
