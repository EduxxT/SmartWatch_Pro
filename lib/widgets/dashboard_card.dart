import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget content; 
  final double? height;
  final Color? cardColor;

  const DashboardCard({
    required this.title,
    required this.content,
    this.height,
    this.cardColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Si la altura es nula, el Column interno no tendrá un límite.
    // Usaremos MainAxisSize.min para asegurarnos de que el Column se ajuste al contenido
    // cuando no se especifica una altura, lo cual es necesario en un SingleChildScrollView.
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cardColor ?? kDarkSecondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Añadimos MainAxisSize.min si no hay una altura definida para asegurar
        // que el Column no intente expandirse si el padre no tiene límites.
        mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max, 
        children: [
          // Título
          Text(
            title,
            style: titleStyle.copyWith(color: cardColor != null ? kDarkPrimaryText : kDarkSecondaryText),
          ),
          const SizedBox(height: 10), 
          // Contenido Principal
          
          // CORRECCIÓN CLAVE: Eliminamos Expanded para que el contenido fluya
          // libremente sin exigir un límite de altura infinito, lo que resuelve el error RenderFlex.
          Align(
            alignment: Alignment.topLeft,
            child: content,
          ),
        ],
      ),
    );
  }
}
