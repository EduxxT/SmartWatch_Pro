// lib/screens/dashboard_screen.dart

import 'package:provider/provider.dart';
import '../modules/bluetooth/bluetooth_service.dart'; 
import '../widgets/last_sleep_card.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/circular_metric_card.dart';
import 'package:app_settings/app_settings.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
        return Consumer<BluetoothService>(
          builder: (context, bluetoothService, child) {
            final isScanning = bluetoothService.isScanning;
            final devices = bluetoothService.availableDevices;

            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(24.0),
                  height: 420,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dispositivos Bluetooth', style: h1Style),
                      const SizedBox(height: 20),

                      // 🔘 Estado general del Bluetooth + dispositivo conectado
                      FutureBuilder<bool>(
                        future: bluetoothService.isBluetoothEnabled(),
                        builder: (context, snapshot) {
                          final enabled = snapshot.data ?? false;
                          final connectedDeviceName =
                              bluetoothService.connectedDevice?.name ?? "";

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
                                  enabled ? Icons.toggle_on : Icons.toggle_off_outlined,
                                  color: enabled ? kAccentColor : Colors.grey,
                                  size: 36,
                                ),
                                onPressed: () async {
                                  if (enabled) {
                                    await bluetoothService.disableBluetooth();
                                  } else {
                                    await bluetoothService.enableBluetooth();
                                  }
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 🔍 Botón de escanear dispositivos
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
                          onPressed: isScanning
                              ? null
                              : () async {
                                  await bluetoothService.startScan();
                                  setState(() {});
                                },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 📋 Lista de dispositivos detectados
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
                                      bluetoothService.connectedDevice?.id ==
                                          device.id;

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
                                            await bluetoothService.disconnect();
                                          } else {
                                            await bluetoothService
                                                .connectToDevice(device);
                                          }
                                          setState(() {});
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
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
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
            Text('Friday, 10 August',
                style: textStyle.copyWith(color: kDarkSecondaryText)),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          Consumer<BluetoothService>(
            builder: (context, bluetoothService, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                  icon: Icon(
                    bluetoothService.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: bluetoothService.isConnected
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
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: kDarkSecondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: cardSpacing),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
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
                        Expanded(
                          flex: 1,
                          child: DashboardCard(
                            title: 'Distance',
                            content: buildSimpleMetricContent('3.8', 'Kilometers'),
                          ),
                        ),
                        const SizedBox(height: cardSpacing),
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
                  const SizedBox(width: cardSpacing),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 13,
                          child: DashboardCard(
                            title: 'Streaks',
                            cardColor: kAccentColor,
                            content: buildStreaksContent('5 Days', 'Hitting 6K+ steps'),
                          ),
                        ),
                        const SizedBox(height: cardSpacing),
                        Expanded(
                          flex: 10,
                          child: LastSleepCard(
                            duration: '7H 46M',
                            timeRange: '12:00 AM - 9:50 AM',
                            hintText: 'Try to sleep earlier tonight',
                          ),
                        ),
                        const SizedBox(height: cardSpacing),
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
