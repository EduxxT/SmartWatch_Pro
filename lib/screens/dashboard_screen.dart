// lib/screens/dashboard_screen.dart

// 1. IMPORTACIONES AÑADIDAS
import 'package:provider/provider.dart';
// Asegúrate de que esta ruta a tu servicio sea la correcta
import '../modules/bluetooth/bluetooth_service.dart'; 

// Importaciones originales
import '../widgets/last_sleep_card.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/circular_metric_card.dart';
// import '../widgets/sleep_card.dart'; // Este import no se usaba en tu código

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Funciones de ayuda para construir el contenido de las tarjetas
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

  // 2. MÉTODO PARA MOSTRAR EL MODAL DE BLUETOOTH
  void _showBluetoothModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkSecondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        // Usamos un Consumer para que el modal se actualice en vivo
        return Consumer<BluetoothService>(
          builder: (context, bluetoothService, child) {
            final isConnected = bluetoothService.isConnected;
            
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado del Dispositivo', style: h1Style),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.check_circle : Icons.error_outline,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isConnected ? 'Conectado a MySmartwatch' : 'Desconectado',
                        style: textStyle.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected ? Colors.redAccent : kAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      // Llama a la función de conectar o desconectar
                      onPressed: () {
                        if (isConnected) {
                          bluetoothService.disconnect();
                        } else {
                          bluetoothService.connectToDevice();
                        }
                      },
                      child: Text(
                        isConnected ? 'Desconectar' : 'Buscar y Conectar',
                        style: textStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
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
        
        // 3. BOTÓN DE BLUETOOTH AÑADIDO A LA APPBAR
        actions: [
          Consumer<BluetoothService>(
            builder: (context, bluetoothService, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                  icon: Icon(
                    // Cambia el icono según el estado
                    bluetoothService.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    // Cambia el color según el estado
                    color: bluetoothService.isConnected
                        ? Colors.blueAccent // Color cuando está conectado
                        : kDarkSecondaryText, // Color cuando está desconectado
                  ),
                  onPressed: () {
                    // Llama a la función que creamos arriba
                    _showBluetoothModal(context);
                  },
                ),
              );
            },
          ),
        ],
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

            // ESTRUCTURA: Row con dos columnas para layout asimétrico
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
                            percent: 3500 / 6000, String: null,
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
                            cardColor: kAccentColor, 
                            content: buildStreaksContent('5 Days', 'Hitting 6K+ steps'),
                          ),
                        ),

                        const SizedBox(height: cardSpacing),
                        
                        // 5. Last Sleep Card (Mediana)
                        Expanded(
                          flex: 10, 
                          child: LastSleepCard( // Usamos LastSleepCard
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
                            percent: 0.90, String: null,
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