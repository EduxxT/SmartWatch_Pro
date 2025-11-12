import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import './../database/local_database.dart'; // ✅ Importa la base local

// =====================
// Bluetooth Provider
// =====================
class BluetoothProvider with ChangeNotifier {
  BluetoothDevice? connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  Timer? _timeSyncTimer;

  bool _isConnecting = false;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  final List<BluetoothDevice> _availableDevices = [];
  List<BluetoothDevice> get availableDevices => List.unmodifiable(_availableDevices);

  // ===== Datos BLE recibidos =====
  int steps = 0;
  int bpm = 0;
  double distanceKm = 0.0;
  int goalSteps = 5000; // ⚙️ Meta por defecto
  double goalHours = 8.0;

  // UUIDs del servicio UART del ESP32
  final Guid UART_SERVICE_UUID = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid UART_TX_UUID = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid UART_RX_UUID = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");

  // =====================
  // Constructor: cargar últimos datos locales
  // =====================
  BluetoothProvider() {
    _loadLastData();
  }

  Future<void> _loadLastData() async {
  final last = await LocalDatabase.getLastRecord();
  if (last != null) {
    steps = last['steps'] ?? 0;
    bpm = last['heart_rate'] ?? 0;
    distanceKm = (last['distance'] ?? 0.0).toDouble();
    goalSteps = last['goal'] ?? 5000;
  }

  goalHours = await LocalDatabase.getSleepGoal();
  debugPrint("📂 Datos restaurados: $steps pasos, ${distanceKm.toStringAsFixed(2)} km, meta pasos $goalSteps, meta sueño $goalHours h");
  notifyListeners();
}

Future<void> updateSleepGoal(double hours) async {
  goalHours = hours;
  await LocalDatabase.saveSleepGoal(hours);
  debugPrint("💾 Meta de sueño guardada: $goalHours h");
  notifyListeners();
}


  // =====================
  // Actualizaciones locales
  // =====================
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

      if (!status.values.every((s) => s.isGranted)) {
        debugPrint("⚠️ Permisos BLE denegados");
        return;
      }
    }

    _availableDevices.clear();
    _isScanning = true;
    notifyListeners();

    FlutterBluePlus.startScan(timeout: Duration(seconds: timeoutSeconds));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;
        String name = result.advertisementData.localName.isNotEmpty
            ? result.advertisementData.localName
            : device.name;

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
      await device.connect(autoConnect: false).timeout(const Duration(seconds: 10));
      connectedDevice = device;
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();

      // Escuchar desconexión
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
      await _sendCurrentTime(device);

      // Actualiza hora cada minuto
      _timeSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
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
              final formatted = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
              final msg = "TIME:$formatted";
              await char.write(msg.codeUnits, withoutResponse: true);
              debugPrint("🕒 Enviada hora: $msg");
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
  // Escuchar datos del ESP32
  // =====================
  Future<void> _setupNotifications(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid == UART_SERVICE_UUID) {
        for (var char in service.characteristics) {
          if (char.uuid == UART_TX_UUID && char.properties.notify) {
            await char.setNotifyValue(true);
            _dataSubscription = char.value.listen((data) async {
              final text = String.fromCharCodes(data);
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

              // ✅ Guarda automáticamente cada vez que llegan datos
              await LocalDatabase.insertData(
                steps: steps,
                heartRate: bpm,
                distance: distanceKm,
                goal: goalSteps,
              );
              debugPrint("💾 Datos guardados en SQLite: $steps pasos, ${distanceKm.toStringAsFixed(2)} km, $bpm bpm");
            });
          }
        }
      }
    }
  }

  // =====================
  // Control del adaptador
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
