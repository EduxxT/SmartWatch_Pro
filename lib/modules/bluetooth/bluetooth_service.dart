import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// =====================
// Bluetooth Provider
// =====================
class BluetoothProvider with ChangeNotifier {
  BluetoothDevice? connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  Timer? _timeSyncTimer; // ⏰ Timer para sincronizar la hora

  bool _isConnecting = false;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  final List<BluetoothDevice> _availableDevices = [];
  List<BluetoothDevice> get availableDevices =>
      List.unmodifiable(_availableDevices);

  // Datos ESP32
  int steps = 0;
  int bpm = 0;
  double distanceKm = 0;

  final Guid UART_SERVICE_UUID = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid UART_TX_UUID = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid UART_RX_UUID = Guid(
    "6E400002-B5A3-F393-E0A9-E50E24DCCA9E",
  ); // 🆕 RX para enviar datos

  void _updateSteps(int newSteps) {
    steps = newSteps;
    notifyListeners();
  }

  void _updateBpm(int newBpm) {
    bpm = newBpm;
    notifyListeners();
  }

  void _updateDistance(double newDistance) {
    distanceKm = newDistance;
    notifyListeners();
  }

  // =====================
  // Escaneo BLE
  // =====================
  Future<void> startScan({int timeoutSeconds = 12}) async {
    if (_isScanning || _isConnecting) return;

    if (Platform.isAndroid) {
      final status = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      if (!status.values.every((s) => s.isGranted)) return;
    }

    _availableDevices.clear();
    _isScanning = true;
    notifyListeners();

    FlutterBluePlus.startScan(timeout: Duration(seconds: timeoutSeconds));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;
        String name = result.advertisementData.localName;
if (name.isEmpty) name = device.name; // fallback

if (name.contains("ESP32S3")) {
  if (!_availableDevices.any((d) => d.id == device.id)) {
    _availableDevices.add(device);
    notifyListeners();
  }
}

      }
    });

    Future.delayed(Duration(seconds: timeoutSeconds), stopScan);
  }

  Future<void> stopScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _isScanning = false;
      notifyListeners();
    }
  }

  // =====================
  // Conexión BLE
  // =====================
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting || _isConnected) return;
    _isConnecting = true;
    notifyListeners();

    try {
      await device.connect(autoConnect: false).timeout(Duration(seconds: 10));
      connectedDevice = device;
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();

      device.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          connectedDevice = null;
          _isConnected = false;
          _dataSubscription?.cancel();
          _timeSyncTimer?.cancel();
          notifyListeners();
        }
      });

      await _setupNotifications(device);

      // 🕒 Enviar hora actual al conectar
      await _sendCurrentTime(device);

      // ⏰ Actualizar hora cada minuto
      _timeSyncTimer = Timer.periodic(Duration(minutes: 1), (_) async {
        if (_isConnected && connectedDevice != null) {
          await _sendCurrentTime(connectedDevice!);
        }
      });
    } catch (e) {
      debugPrint("⚠️ Error al conectar: $e");
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
    }
  }

  // =====================
  // Enviar hora actual al ESP32
  // =====================
  Future<void> _sendCurrentTime(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid == UART_SERVICE_UUID) {
          for (var char in service.characteristics) {
            if (char.uuid == UART_RX_UUID && char.properties.write) {
              final now = DateTime.now();
              final formattedTime =
                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
              final message = "TIME:$formattedTime";
              await char.write(message.codeUnits, withoutResponse: true);
              debugPrint("🕒 Enviada hora al ESP32: $message");
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error enviando hora: $e");
    }
  }

  // =====================
  // Notificaciones desde ESP32
  // =====================
  Future<void> _setupNotifications(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid == UART_SERVICE_UUID) {
        for (var char in service.characteristics) {
          if (char.uuid == UART_TX_UUID && char.properties.notify) {
            await char.setNotifyValue(true);
            _dataSubscription = char.value.listen((data) {
              final text = String.fromCharCodes(
                data,
              ); // "STEPS:3500,BPM:85,DIST:2.4"
              final parts = text.split(',');
              for (var p in parts) {
                final kv = p.split(':');
                if (kv.length == 2) {
                  final key = kv[0].toUpperCase();
                  final value = kv[1];
                  if (key == 'STEPS') _updateSteps(int.tryParse(value) ?? 0);
                  if (key == 'BPM') _updateBpm(int.tryParse(value) ?? 0);
                  if (key == 'DIST' || key == 'DISTANCE') {
                    _updateDistance(double.tryParse(value) ?? 0.0);
                  }
                }
              }
            });
          }
        }
      }
    }
  }

  // =====================
  // Encender/apagar BLE
  // =====================
  Future<void> enableBluetooth() async {
    if (Platform.isAndroid) await FlutterBluePlus.turnOn();
    notifyListeners();
  }

  Future<void> disableBluetooth() async {
    if (Platform.isAndroid) await FlutterBluePlus.turnOff();
    await disconnect();
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _scanSubscription?.cancel();
    await _dataSubscription?.cancel();
    _timeSyncTimer?.cancel();
    if (connectedDevice != null) await connectedDevice!.disconnect();
    connectedDevice = null;
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      final state = FlutterBluePlus.adapterStateNow;
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }
}
