import 'package:flutter/material.dart';

class AlertContainer{

  final String text;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const AlertContainer({

    required this.text,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });
}