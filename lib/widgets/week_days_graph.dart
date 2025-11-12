import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class WeekDaysGraph extends StatelessWidget {
  final List<Map<String, dynamic>> sleepData;

  const WeekDaysGraph({
    required this.sleepData,
    super.key,
  });

  // Helper widget para construir una barra individual
  Widget _buildBar(String day, String hours, double heightFactor) {
    const Color barTrackColor = kDarkSecondaryBackground;
    const double maxHeight = 90.0; // Reduce from 100.0 to 90.0

    return Column(
      // Alineamos las columnas de las barras al final
      mainAxisAlignment: MainAxisAlignment.end, 
      children: [
        // La barra en sí
        Container(
          height: maxHeight,
          width: 25,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: barTrackColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            height: maxHeight * heightFactor, // Altura relativa
            decoration: BoxDecoration(
              color: day == 'S' ? kAccentColor : kDarkSecondaryText, 
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 4), // Reduce spacing
        // Horas
        Text(
          hours,
          style: textStyle.copyWith(color: kDarkPrimaryText, fontSize: 10), // Reduce font size
        ),
        const SizedBox(height: 2), // Reduce spacing
        // Día
        Text(
          day,
          style: textStyle.copyWith(color: kDarkSecondaryText, fontSize: 10), // Reduce font size
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cálculo de Altura Necesaria:
    // Título y Espacio: ~40.0 (asumiendo fuente de 20 + padding vertical) + 20.0 (SizedBox)
    // Contenido de la Gráfica (barra + texto): 100 + 8 + 12 + 4 + 12 = 136.0
    // Padding vertical del Container: 16 * 2 = 32.0
    // Altura total mínima necesaria: ~40 + 20 + 136 + 32 = 228.0 
    // Dado que el error era de 10.0, el valor anterior de 200.0 era insuficiente.
    
    // CORRECCIÓN: Aumentamos la altura a un valor seguro.
    const double safeHeight = 230.0;

    return Container(
      // Remove: height: safeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week Days', style: titleStyle.copyWith(color: kDarkPrimaryText)),
          const SizedBox(height: 20),

          // Altura para las barras y el texto (136.0)
          // Mover la declaración fuera del widget tree
          SizedBox(
            height: 136.0, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sleepData.map((data) {
                // Se mantiene la corrección de nulidad para seguridad
                final String day = (data['day'] as String?) ?? 'N/A';
                final String hours = (data['hours'] as String?) ?? '0H'; 
                final double factor = (data['factor'] as double?) ?? 0.0;
                
                return _buildBar(day, hours, factor);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class YourWidget extends StatelessWidget {
  final List<Map<String, dynamic>> yourSleepData;

  const YourWidget({
    required this.yourSleepData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your App Title')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Other widgets
              WeekDaysGraph(sleepData: yourSleepData),
              // Other widgets
            ],
          ),
        ),
      ),
    );
  }
}
