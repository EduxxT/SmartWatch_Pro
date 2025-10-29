import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/local_database.dart';

/// Servicio que gestiona la conexión BLE con ChangeNotifier
class BluetoothService with ChangeNotifier {
  BluetoothDevice? connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Lista de dispositivos BLE encontrados
  final List<BluetoothDevice> _availableDevices = [];
  List<BluetoothDevice> get availableDevices => List.unmodifiable(_availableDevices);

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  /// UUIDs del servicio UART BLE (modifica si usas otro)
  final Guid UART_SERVICE_UUID = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid UART_RX_UUID = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // escribir al ESP32
  final Guid UART_TX_UUID = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // leer del ESP32

  /// Inicia el escaneo BLE
  Future<void> startScan({int timeoutSeconds = 12}) async {
    if (_isScanning || _isConnecting) return;

    print("🛠️ Verificando permisos...");
    Map<Permission, PermissionStatus> statuses;

    if (Platform.isAndroid) {
      statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    } else {
      statuses = await [Permission.bluetooth].request();
    }

    if (!statuses.values.every((s) => s.isGranted)) {
      print("❌ Permisos denegados.");
      return;
    }

    _availableDevices.clear();
    _isScanning = true;
    notifyListeners();

    print("🔎 Iniciando escaneo BLE...");
    FlutterBluePlus.startScan(timeout: Duration(seconds: timeoutSeconds));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;

        // 🔹 Filtrado flexible para ESP32-S3
        bool isTargetDevice = device.name == "ESP32S3_UART" ||
            device.id.id.toLowerCase().contains("esp32");

        bool alreadyAdded = _availableDevices.any((d) => d.id == device.id);

        if (isTargetDevice && !alreadyAdded) {
          _availableDevices.add(device);
          notifyListeners();
          print("📱 Dispositivo detectado: ${device.name} (${device.id})");
        }
      }
    }, onError: (e) {
      print("❌ Error de escaneo: $e");
      stopScan();
    });

    // Detener escaneo automáticamente
    Future.delayed(Duration(seconds: timeoutSeconds), () => stopScan());
  }

  /// Detiene el escaneo
  Future<void> stopScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _isScanning = false;
      notifyListeners();
      print("🛑 Escaneo detenido.");
    }
  }

  /// Conecta a un dispositivo BLE
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting || _isConnected) return;

    print("🔗 Conectando a ${device.name}...");
    _isConnecting = true;
    notifyListeners();

    try {
      await device.connect(autoConnect: false);
      connectedDevice = device;
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
      print("✅ Conectado a ${device.name}");

      _listenToDisconnects(device);
      await _listenToData(device);
    } catch (e) {
      print("❌ Error al conectar: $e");
      _isConnecting = false;
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Escucha desconexiones automáticas
  void _listenToDisconnects(BluetoothDevice device) {
    device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        print("❌ Dispositivo desconectado: ${device.name}");
        _dataSubscription?.cancel();
        connectedDevice = null;
        _isConnected = false;
        notifyListeners();
      }
    });
  }

  /// Suscribe a las características del UART BLE
  Future<void> _listenToData(BluetoothDevice device) async {
    try {
      var services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid == UART_SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid == UART_TX_UUID && characteristic.properties.notify) {
              await characteristic.setNotifyValue(true);
              _dataSubscription = characteristic.value.listen((value) {
                final data = String.fromCharCodes(value);
                _processData(data);
              }, onError: (e) {
                print("❌ Error escuchando característica: $e");
              });
              print("✅ Suscrito a TX: ${characteristic.uuid}");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error al descubrir servicios: $e");
    }
  }

  /// Procesa y guarda los datos recibidos
  void _processData(String data) {
    if (data.trim().isEmpty) return;

    try {
      // Ejemplo de datos en formato simplificado
      // "steps:1000,hr:75,activity:walk"
      final parts = data.split(',');
      if (parts.length < 3) return;

      final steps = int.tryParse(parts[0].split(':')[1]);
      final hr = int.tryParse(parts[1].split(':')[1]);
      final activity = parts[2].split(':')[1];

      if (steps != null && hr != null) {
        LocalDatabase.insertData(
          steps: steps,
          heartRate: hr,
          activityType: activity,
        );
        print("💾 Guardado: $steps pasos, $hr bpm, actividad: $activity");
      }
    } catch (e) {
      print("❌ Error procesando datos: $e");
    }
  }

  // =========================================================
  // 🔷 Funciones de Bluetooth
  // =========================================================

  Future<bool> isBluetoothEnabled() async {
    try {
      final state = await FlutterBluePlus.adapterStateNow;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      print("⚠️ Error verificando Bluetooth: $e");
      return false;
    }
  }

  String get connectedDeviceName => connectedDevice?.name ?? "";

  Future<void> disableBluetooth() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOff();
        print("🔵 Bluetooth apagado.");
        await disconnect();
      }
    } catch (e) {
      print("❌ Error apagando Bluetooth: $e");
    }
    notifyListeners();
  }

  Future<void> enableBluetooth() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        print("🔵 Bluetooth activado.");
      }
    } catch (e) {
      print("❌ Error activando Bluetooth: $e");
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _scanSubscription?.cancel();
    await _dataSubscription?.cancel();

    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      print("🔌 Desconectado de ${connectedDevice!.name}");
      connectedDevice = null;
    }

    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }
}
