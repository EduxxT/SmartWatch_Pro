// lib/screens/dashboard_screen.dart

import '../widgets/last_sleep_card.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/circular_metric_card.dart';
import '../widgets/sleep_card.dart'; // Importamos el nuevo componente

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // ... (Funciones buildSimpleMetricContent y buildStreaksContent se mantienen)

  Widget buildSimpleMetricContent(String metric, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metric, style: h1Style.copyWith(color: kDarkPrimaryText)),
        Text(unit, style: textStyle.copyWith(color: kDarkSecondaryText)),
      ],
    );
  }

  Widget buildStreaksContent(String days, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(days, style: h1Style.copyWith(color: kDarkPrimaryText)),
        Text(detail, style: textStyle.copyWith(color: kDarkSecondaryText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // El padding de 20 en las orillas se mantiene en el SingleChildScrollView
    const double cardSpacing = 20.0; // Espaciado entre cajas y columnas

    return Scaffold(
      backgroundColor: kDarkPrimaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menu de inicio', style: h1Style),
            Text('Friday, 10 August', style: textStyle.copyWith(color: kDarkSecondaryText)),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          children: [
            // Contenedor superior grande (Mismo padding que el body)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: kDarkSecondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            const SizedBox(height: cardSpacing), // Espacio entre contenedor y tarjetas

            // NUEVA ESTRUCTURA: Row con dos columnas para layout asimétrico
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- COLUMNA IZQUIERDA (Walk, Distance, Heart) ---
                  Expanded(
                    child: Column(
                      children: [
                        // 1. Walk Card (Usamos flex: 1)
                        Expanded(
                          flex: 1,
                          child: CircularMetricCard(
                            title: 'Walk',
                            metricText: '3500',
                            unitText: 'Steps',
                            percent: 3500 / 6000,
                          ),
                        ),
                        const SizedBox(height: cardSpacing),
                        // 2. Distance Card (Usamos flex: 1)
                        Expanded(
                          flex: 1,
                          child: DashboardCard(
                            title: 'Distance',
                            content: buildSimpleMetricContent('3.8', 'Kilometers'),
                          ),
                        ),
                        const SizedBox(height: cardSpacing),
                        // 3. Heart Card (Usamos flex: 1)
                        Expanded(
                          flex: 1,
                          child: DashboardCard(
                            title: 'Heart',
                            content: buildSimpleMetricContent('85', 'BPM'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: cardSpacing), // Espacio horizontal entre columnas

                  // --- COLUMNA DERECHA (Streaks, Last Sleep, Battery) ---
                   Expanded(
                    child: Column(
                      children: [
                        // 4. Streaks Card (Más alta y color Violeta)
                        Expanded(
                          flex: 13, 
                          child: DashboardCard(
                            title: 'Streaks',
                            // PASAMOS EL COLOR DE ACENTO AQUÍ
                            cardColor: kAccentColor, 
                            content: buildStreaksContent('5 Days', 'Hitting 6K+ steps'),
                          ),
                        ),

                        const SizedBox(height: cardSpacing),
                        
                        // 5. Last Sleep Card (Mediana)
                        Expanded(
                          flex: 10, 
                          child: LastSleepCard( // <--- CORRECCIÓN: Usamos LastSleepCard
                            duration: '7H 46M',
                            timeRange: '12:00 AM - 9:50 AM',
                            hintText: 'Try to sleep earlier tonight',
                          ),
                        ),
                        
                        
                        const SizedBox(height: cardSpacing),
                        
                        // 6. Battery Card 
                        Expanded(
                          flex: 12, 
                          child: CircularMetricCard(
                            title: 'Battery',
                            metricText: '90',
                            unitText: 'Percent',
                            percent: 0.90,
                          ),
                        ),
                      ],
                    ),
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