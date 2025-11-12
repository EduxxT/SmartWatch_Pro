// lib/widgets/goal_quality_card.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GoalQualityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;

  const GoalQualityCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.titleColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: titleStyle.copyWith(color: titleColor),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textStyle.copyWith(color: titleColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}