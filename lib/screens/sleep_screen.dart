// lib/screens/sleep_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/sleep_header_card.dart';
import '../widgets/goal_quality_card.dart';
import '../widgets/week_days_graph.dart';
import '../widgets/last_sleep_card.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({Key? key}) : super(key: key);

  // Datos de ejemplo para la gráfica
  static final List<Map<String, dynamic>> _mockSleepData = [
    {'day': 'M', 'hours': '7h', 'factor': 0.8},
    {'day': 'T', 'hours': '7h', 'factor': 0.8},
    {'day': 'W', 'hours': '7h', 'factor': 0.8},
    {'day': 'T', 'hours': '7h', 'factor': 0.8},
    {'day': 'F', 'hours': '7h', 'factor': 0.8},
    {'day': 'S', 'hours': '7h', 'factor': 0.8},
    {'day': 'S', 'hours': '7h', 'factor': 0.9},
  ];

  @override
  Widget build(BuildContext context) {
    const double screenPadding = 20.0;
    const double cardSpacing = 20.0;

    return Scaffold(
      backgroundColor: kDarkPrimaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: screenPadding,
        title: Text('Mi sueño 🌚', style: h1Style),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(screenPadding),
        child: Column(
          children: [
            // 1. Tarjeta de Encabezado de Sueño (Circular Indicator)
            const SleepHeaderCard(
              currentHours: 8.0,
              goalHours: 8.0,
            ),
            
            const SizedBox(height: cardSpacing),
            
            // 2. Tarjetas de Meta y Calidad (Fila de 2)
            Row(
              children: [
                // Set Goal
                GoalQualityCard(
                  title: 'Set Goal',
                  subtitle: 'Tap to edit',
                  backgroundColor: kAccentColor,
                  titleColor: kDarkPrimaryText,
                ),
                
                const SizedBox(width: cardSpacing),
                
                // Quality
                GoalQualityCard(
                  title: 'Quality',
                  subtitle: 'Last night',
                  backgroundColor: kDarkSecondaryBackground,
                  titleColor: kDarkPrimaryText,
                ),
              ],
            ),
            
            const SizedBox(height: cardSpacing),
            
            // 3. Gráfica de Días de la Semana
            WeekDaysGraph(sleepData: _mockSleepData),
            
            const SizedBox(height: cardSpacing),
            
            // 4. Último Sueño (Reutilizando la lógica de LastSleepCard)
            const LastSleepCard(
              duration: '7H 45M',
              timeRange: '12:00 AM - 9:50 AM',
              hintText: 'Try to sleep earlier tonight',
            ),
          ],
        ),
      ),
      // Mantenemos la barra de navegación para fines de demostración, aunque en la app real
      // esto se manejaría en un widget padre (e.g., el Home/Main screen).
    );
  }
}