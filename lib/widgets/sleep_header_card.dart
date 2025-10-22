// lib/widgets/sleep_header_card.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/app_theme.dart';

class SleepHeaderCard extends StatelessWidget {
  final double currentHours;
  final double goalHours;
  final String? metricLabel; // Propiedad opcional

  const SleepHeaderCard({
    required this.currentHours,
    required this.goalHours,
    this.metricLabel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percent = currentHours / goalHours;
    
    // Si metricLabel no es nulo, estamos en Activity, y el valor del double representa KILO-STEPS (ej: 6.5 -> 6500)
    // Si metricLabel es nulo, estamos en Sleep, y el valor del double representa HORAS.
    final bool isActivityView = metricLabel != null;

    return Container(
      decoration: BoxDecoration(
        color: kDarkSecondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Título 'You have slept X hours Today' / 'You have walked X steps Today'
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: titleStyle.copyWith(color: kDarkPrimaryText, height: 1.4),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: isActivityView ? 'walked ' : 'slept ', // Controla el verbo
                    style: titleStyle.copyWith(color: kDarkPrimaryText),
                  ),
                  TextSpan(
                    // Valor numérico: steps si es Activity, horas si es Sleep
                    text: isActivityView
                        ? '${(currentHours * 1000).toInt()}'
                        : '${currentHours.toInt()}',
                    style: titleStyle.copyWith(
                      color: kAccentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // CORRECCIÓN CLAVE: Controla el resto del texto.
                  // Si es Activity, muestra ' steps Today'. Si es Sleep, muestra ' hours Today'.
                  TextSpan(text: isActivityView ? ' steps Today' : ' hours Today'), 
                ],
              ),
            ),
          ),
          
          // Indicador Circular
          CircularPercentIndicator(
            radius: 70.0, 
            lineWidth: 10.0,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // Valor numérico para el centro del círculo
                  isActivityView ? '${(currentHours * 1000).toInt()}' : '${currentHours.toInt()}H',
                  style: h1Style.copyWith(color: kDarkPrimaryText, fontSize: 32),
                ),
                Text(
                  // Unidad para el centro del círculo
                  isActivityView ? 'Steps' : 'Hours',
                  style: textStyle.copyWith(color: kDarkSecondaryText),
                ),
              ],
            ),
            progressColor: kAccentColor,
            backgroundColor: kDarkSecondaryBackground.withOpacity(0.5),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          
          const SizedBox(height: 25),
          
          // Métricas Avg y Goal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Distance', style: textStyle.copyWith(color: kDarkSecondaryText)),
                  // Distancia (si es Activity) o Promedio (si es Sleep)
                  Text(isActivityView ? '4.2km' : '8H', style: titleStyle.copyWith(color: kDarkPrimaryText)),
                ],
              ),
              Column(
                children: [
                  Text('Goal', style: textStyle.copyWith(color: kDarkSecondaryText)),
                  // Goal de Steps (si es Activity) o Goal de Sueño (si es Sleep)
                  Text(isActivityView ? '10,000' : '8H 50M', style: titleStyle.copyWith(color: kDarkPrimaryText)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}