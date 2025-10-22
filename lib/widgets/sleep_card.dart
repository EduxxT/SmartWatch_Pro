// lib/widgets/sleep_card.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dashboard_card.dart';

class SleepCard extends StatelessWidget {
  final String duration;
  final String timeRange;

  const SleepCard({
    required this.duration,
    required this.timeRange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos el DashboardCard para mantener el estilo de la tarjeta
    return DashboardCard(
      title: 'Last Sleep',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duración grande (7H 46M)
          Text(
            duration,
            style: h1Style.copyWith(color: kDarkPrimaryText),
          ),
          // Rango de tiempo pequeño (12:00 AM - 9:50 AM)
          Text(
            timeRange,
            style: textStyle.copyWith(color: kDarkSecondaryText),
          ),
        ],
      ),
    );
  }
}