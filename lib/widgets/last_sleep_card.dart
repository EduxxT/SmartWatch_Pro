// lib/widgets/last_sleep_card.dart (CORREGIDO)

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LastSleepCard extends StatelessWidget {
  final String duration;
  final String timeRange;
  final String? hintText; // <--- Opcional: Correcto

  const LastSleepCard({
    required this.duration,
    required this.timeRange,
    this.hintText, // <--- No requerido: Correcto
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos la lista de widgets para el Column
    List<Widget> contentChildren = [
      Text('Last Sleep', style: titleStyle.copyWith(color: kDarkPrimaryText)),
      const SizedBox(height: 8),
      Text(
        duration,
        style: h1Style.copyWith(color: kDarkPrimaryText),
      ),
      Text(
        timeRange,
        style: textStyle.copyWith(color: kDarkSecondaryText),
      ),
    ];
    
    // Si hintText existe y no está vacío, lo añadimos a la lista
    if (hintText != null && hintText!.isNotEmpty) {
      contentChildren.add(const SizedBox(height: 8)); // Espacio antes del hint
      contentChildren.add(
        Text(
          // Solución: Usamos el operador ! porque ya verificamos que no es nulo
          hintText!, 
          style: textStyle.copyWith(color: kDarkSecondaryText.withOpacity(0.6), fontStyle: FontStyle.italic, fontSize: 12),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: kDarkSecondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Usamos la lista de widgets generada
        children: contentChildren,
      ),
    );
  }
}