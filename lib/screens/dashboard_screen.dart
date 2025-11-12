import 'package:provider/provider.dart';
import '../modules/bluetooth/bluetooth_service.dart';
import '../widgets/last_sleep_card.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/circular_metric_card.dart';
import '../widgets/banner_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  void _showBluetoothModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkSecondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Consumer<BluetoothProvider>(
          builder: (context, btProvider, child) {
            final isScanning = btProvider.isScanning;
            final devices = btProvider.availableDevices;

            return Container(
              padding: const EdgeInsets.all(24.0),
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dispositivos Bluetooth', style: h1Style),
                  const SizedBox(height: 20),
                  FutureBuilder<bool>(
                    future: btProvider.isBluetoothEnabled(),
                    builder: (context, snapshot) {
                      final enabled = snapshot.data ?? false;
                      final connectedDeviceName =
                          btProvider.connectedDevice?.name ?? "";

                      return Row(
                        children: [
                          Icon(
                            enabled
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: enabled ? kAccentColor : Colors.redAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enabled
                                      ? 'Bluetooth activado'
                                      : 'Bluetooth desactivado',
                                  style: textStyle.copyWith(
                                    fontSize: 16,
                                    color: enabled
                                        ? kDarkPrimaryText
                                        : Colors.redAccent,
                                  ),
                                ),
                                if (connectedDeviceName.isNotEmpty)
                                  Text(
                                    'Conectado a: $connectedDeviceName',
                                    style: textStyle.copyWith(
                                      fontSize: 14,
                                      color: kDarkSecondaryText,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              enabled
                                  ? Icons.toggle_on
                                  : Icons.toggle_off_outlined,
                              color: enabled ? kAccentColor : Colors.grey,
                              size: 36,
                            ),
                            onPressed: () async {
                              if (enabled) {
                                await btProvider.disableBluetooth();
                              } else {
                                await btProvider.enableBluetooth();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        isScanning
                            ? Icons.hourglass_bottom
                            : Icons.search_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        isScanning
                            ? "Buscando dispositivos..."
                            : "Buscar dispositivos cercanos",
                        style: textStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isScanning ? null : btProvider.startScan,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: devices.isEmpty
                        ? Center(
                            child: Text(
                              isScanning
                                  ? "Buscando dispositivos..."
                                  : "No se detectaron dispositivos.",
                              style: textStyle.copyWith(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              final connected =
                                  btProvider.connectedDevice?.id == device.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: connected
                                      ? kAccentColor.withOpacity(0.2)
                                      : kDarkPrimaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.watch,
                                    color: connected
                                        ? kAccentColor
                                        : kDarkSecondaryText,
                                  ),
                                  title: Text(
                                    device.name.isNotEmpty
                                        ? device.name
                                        : "Sin nombre",
                                    style: titleStyle,
                                  ),
                                  subtitle: Text(
                                    device.id.toString(),
                                    style: textStyle,
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: connected
                                          ? Colors.redAccent
                                          : kAccentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (connected) {
                                        await btProvider.disconnect();
                                      } else {
                                        await btProvider.connectToDevice(
                                          device,
                                        );
                                      }
                                    },
                                    child: Text(
                                      connected ? "Desconectar" : "Conectar",
                                      style: textStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
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
    const double cardSpacing = 20.0;

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
            Text(
              'Friday, 10 August',
              style: textStyle.copyWith(color: kDarkSecondaryText),
            ),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, btProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                  icon: Icon(
                    btProvider.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: btProvider.isConnected
                        ? Colors.blueAccent
                        : kDarkSecondaryText,
                  ),
                  onPressed: () => _showBluetoothModal(context),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const BannerConFondoHora(),
      const SizedBox(height: cardSpacing),

      // 🔹 Contenedor del grid de 2x2
      GridView.count(
        crossAxisCount: 2, // 2 columnas
        shrinkWrap: true, // para que se ajuste al contenido
        physics: const NeverScrollableScrollPhysics(), // evita scroll interno
        crossAxisSpacing: cardSpacing,
        mainAxisSpacing: cardSpacing,
        childAspectRatio: 1, // cuadradas (ajusta a 1.1 o 0.9 según prefieras)
        children: [
          // 🔸 Tarjeta 1 - Pasos
          Consumer<BluetoothProvider>(
            builder: (context, bt, child) {
              return CircularMetricCard(
                title: 'Walk',
                metricText: bt.steps.toString(),
                unitText: 'Steps',
                percent: (bt.steps / 6000).clamp(0.0, 1.0),
              );
            },
          ),

          // 🔸 Tarjeta 2 - Distancia
          Consumer<BluetoothProvider>(
            builder: (context, bt, child) {
              return DashboardCard(
                title: 'Distance',
                content: buildSimpleMetricContent(
                  bt.distanceKm.toStringAsFixed(2),
                  'Kilometers',
                ),
              );
            },
          ),

          // 🔸 Tarjeta 3 - Ritmo cardíaco
          Consumer<BluetoothProvider>(
            builder: (context, bt, child) {
              return DashboardCard(
                title: 'Heart',
                content: buildSimpleMetricContent(
                  bt.bpm.toString(),
                  'BPM',
                ),
              );
            },
          ),

          // 🔸 Tarjeta 4 - Sueño (ajustada en tamaño)
          AspectRatio(
            aspectRatio: 1 / 1.1, // un poco más compacta
            child: LastSleepCard(
              duration: '7H 46M',
              timeRange: '12:00 AM - 9:50 AM',
              hintText: 'Try to sleep earlier tonight 😴',
            ),
          ),
        ],
      ),

      const SizedBox(height: cardSpacing),

      // 🔹 Fila final si quieres agregar más métricas
      Row(
        children: [
          Expanded(
            child: DashboardCard(
              title: 'Streaks',
              cardColor: kAccentColor,
              content: buildStreaksContent('5 Days', 'Hitting 6K+ steps'),
            ),
          ),
          const SizedBox(width: cardSpacing),
          const Expanded(
            child: CircularMetricCard(
              title: 'Battery',
              metricText: '90',
              unitText: 'Percent',
              percent: 0.90,
            ),
          ),
        ],
      ),
    ],
  ),
),

    );
  }
}