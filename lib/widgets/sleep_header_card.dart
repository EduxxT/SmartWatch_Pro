import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/app_theme.dart';

class SleepHeaderCard extends StatelessWidget {
  final double currentHours;
  final double goalHours;
  final String? metricLabel; // Si no es nulo, representa "Activity" (Steps)
  final int? strikeCount; // Nueva propiedad opcional para el modo Sleep
  final double? goalSteps;

  const SleepHeaderCard({
    required this.currentHours,
    required this.goalHours,
    this.metricLabel,
    this.strikeCount,
    super.key,
    this.goalSteps, required bool isActivityView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActivityView = metricLabel != null;
    final double percent = (currentHours / goalHours).clamp(0.0, 1.0);

    // Texto base para título superior
    String actionWord = isActivityView ? 'walked' : 'slept';
    String metricValue = isActivityView
    ? currentHours.toInt().toString()
    : currentHours.toStringAsFixed(1);
    String metricUnit = isActivityView ? 'steps' : 'hours';

    return Container(
      decoration: BoxDecoration(
        color: kDarkSecondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          // === Encabezado dinámico ===
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: titleStyle.copyWith(color: kDarkPrimaryText, height: 1.4),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '$actionWord ',
                    style: titleStyle.copyWith(color: kDarkPrimaryText),
                  ),
                  TextSpan(
                    text: metricValue,
                    style: titleStyle.copyWith(
                      color: kAccentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' $metricUnit Today'),
                ],
              ),
            ),
          ),

          // === Indicador Circular ===
          CircularPercentIndicator(
            radius: 75.0,
            lineWidth: 10.0,

            percent: percent,
            animation: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isActivityView
    ? '${currentHours.toInt()}'
    : '${currentHours.toStringAsFixed(1)}H',
                  style: h1Style.copyWith(color: kDarkPrimaryText, fontSize: 30),
                ),
                Text(
                  isActivityView ? 'Steps' : 'Hours',
                  style: textStyle.copyWith(color: kDarkSecondaryText),
                ),
              ],
            ),
            progressColor: kAccentColor,
            backgroundColor: kDarkSecondaryBackground.withOpacity(0.4),
            circularStrokeCap: CircularStrokeCap.round,
          ),

          const SizedBox(height: 25),

          // === Métricas secundarias ===
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Column(
      children: [
        Text(
          isActivityView ? 'Distance' : 'Average',
          style: textStyle.copyWith(color: kDarkSecondaryText),
        ),
        Text(
          isActivityView
              ? '${((currentHours * 0.78) / 1000).toStringAsFixed(2)} km'
              : '8H',
          style: titleStyle.copyWith(color: kDarkPrimaryText),
        ),
      ],
    ),
    Column(
  children: [
    Text('Goal', style: textStyle.copyWith(color: kDarkSecondaryText)),
    Text(
      isActivityView
          ? (goalSteps ?? 0).toString() // ✅ usa la meta pasada
          : '${goalHours.toStringAsFixed(1)}H',
      style: titleStyle.copyWith(color: kDarkPrimaryText),
    ),
  ],
),

  ],
),


          // === Strike (solo modo Sleep) ===
          if (!isActivityView && strikeCount != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Strike: $strikeCount day${strikeCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
