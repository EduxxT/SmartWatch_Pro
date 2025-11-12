// lib/widgets/circular_metric_card.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; 
import '../utils/app_theme.dart';
import 'dashboard_card.dart';

class CircularMetricCard extends StatelessWidget {
  final String title;
  final String metricText;
  final String unitText;
  final double percent;

   const CircularMetricCard({
    required this.title,
    required this.metricText,
    required this.unitText,
    required this.percent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      content: Center(
        child: CircularPercentIndicator(
          // MODIFICACIÓN 1: Reducir el radio para ganar espacio vertical
          radius: 50.0, // Antes era 55.0 
          lineWidth: 8.0,
          percent: percent,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                metricText,
                style: titleStyle.copyWith(color: kDarkPrimaryText),
              ),
              Text(
                unitText,
                style: textStyle.copyWith(color: kDarkSecondaryText),
              ),
            ],
          ),
          progressColor: kAccentColor,
          backgroundColor: kDarkSecondaryBackground.withOpacity(0.5), 
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ),
    );
  }
}