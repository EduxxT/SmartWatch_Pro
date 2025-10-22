import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/sleep_header_card.dart'; // Reutilizamos el header circular
import '../widgets/goal_quality_card.dart'; // Reutilizamos la tarjeta de meta
import '../widgets/week_days_graph.dart'; // Reutilizamos la gráfica
import '../widgets/dashboard_card.dart'; // Reutilizamos la tarjeta base

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  // Datos de mock para la gráfica de actividad
  static final List<Map<String, dynamic>> _mockActivityData = [
    {'day': 'M', 'factor': 0.7, 'label': '2,390', 'hours': '2.3k'}, // Cambiado 'hours' a 'label'
    {'day': 'T', 'factor': 0.8, 'label': '3.8', 'hours': '3.8k'},
    {'day': 'W', 'factor': 0.9, 'label': '4,500', 'hours': '4.5k'},
    {'day': 'T', 'factor': 0.75, 'label': '2.1', 'hours': '2.1k'},
    {'day': 'F', 'factor': 0.85, 'label': '5,100', 'hours': '5.1k'},
    {'day': 'S', 'factor': 0.95, 'label': '6.0', 'hours': '6.0k'},
    {'day': 'S', 'factor': 0.8, 'label': '4,800', 'hours': '4.8k'},
  ];

  // Helper Widget para la información debajo de la gráfica
  Widget _buildGraphLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // USAMOS Expanded para asegurar que los Column internos no causen conflictos
          // y que se dividan el espacio uniformemente
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Steps', style: textStyle.copyWith(color: kDarkSecondaryText)),
                Text('2,390', style: titleStyle.copyWith(color: kDarkPrimaryText)), // Mock Data
                Text('M', style: textStyle.copyWith(color: kDarkSecondaryText)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kilometers', style: textStyle.copyWith(color: kDarkSecondaryText)),
                Text('3.8', style: titleStyle.copyWith(color: kDarkPrimaryText)), // Mock Data
                Text('T', style: textStyle.copyWith(color: kDarkSecondaryText)),
              ],
            ),
          ),
          // El resto de los días no tienen labels debajo en la imagen
        ],
      ),
    );
  }

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
        title: Text('My Activity', style: h1Style),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(screenPadding),
        child: Column(
          children: [
            // 1. Cabecera de Actividad (Reutilizando SleepHeaderCard)
            SleepHeaderCard(
              currentHours: 6.5, 
              goalHours: 10.0, 
              // Usamos las claves existentes, aunque el nombre es engañoso para Activity
              // La implementación real de SleepHeaderCard probablemente no tiene metricLabel
              // Simplemente adaptamos los datos.
            ),
            
            const SizedBox(height: cardSpacing),
            
            // 2. Gráfica de Días de la Semana (Reutilizando WeekDaysGraph)
            // Ya tiene altura fija implícita gracias a la barra de 100.0
            WeekDaysGraph(
              sleepData: _mockActivityData, 
            ),
            
            const SizedBox(height: 10),
            
            // Labels de la gráfica (Steps y Kilometers)
            _buildGraphLabels(),
            
            const SizedBox(height: cardSpacing),
            
            // 3. Tarjetas de Meta y Tiempo Activo (Fila de 2)
            Row(
              children: [
                // CORRECCIÓN CLAVE: Envolver en Expanded para dividir el espacio horizontal.
                Expanded( // <-- AÑADIDO
                  child: GoalQualityCard(
                    title: 'Set Goal',
                    subtitle: '5000',
                    backgroundColor: kAccentColor,
                    titleColor: kDarkPrimaryText,
                  ),
                ),
                
                const SizedBox(width: cardSpacing),
                
                // CORRECCIÓN CLAVE: Envolver en Expanded para dividir el espacio horizontal.
                Expanded( // <-- AÑADIDO
                  child: GoalQualityCard(
                    title: 'Active Time',
                    subtitle: 'Keep moving!',
                    backgroundColor: kDarkSecondaryBackground,
                    titleColor: kDarkPrimaryText,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: cardSpacing),
            
            // 4. Tarjeta "Let's Move!" (Usando DashboardCard)
            DashboardCard(
              title: "Let's Move!",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A good start! You\'ve got this',
                    style: textStyle.copyWith(color: kDarkSecondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
