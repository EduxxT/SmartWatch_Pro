import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../database/local_database.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// 1. Agregamos 'with ChangeNotifier'
class BluetoothService with ChangeNotifier {
  BluetoothDevice? connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _dataSubscription;

  // Bandera para evitar múltiples intentos de conexión
  bool _isConnecting = false;

  // 2. Agregamos la variable de estado y su 'getter'
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // --- OBTÉN ESTOS VALORES DE LA DOCUMENTACIÓN DE TU RELOJ ---
  final String TARGET_DEVICE_NAME = "MySmartwatch";
  // final Guid SERVICE_UUID = Guid("TU-SERVICE-UUID-AQUÍ");
  // final Guid CHARACTERISTIC_UUID = Guid("TU-CHARACTERISTIC-UUID-AQUÍ");
  // ---------------------------------------------------------


  Future<void> connectToDevice() async {
    print("Revisando permisos..."); // Usando el _log que hicimos
  Map<Permission, PermissionStatus> statuses;

  if (Platform.isAndroid) {
    statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  } else {
    // Para iOS
    statuses = await [
      Permission.bluetooth,
    ].request();
  }

  // Revisa si algún permiso fue denegado
  bool allGranted = statuses.values.every((status) => status.isGranted);
  if (!allGranted) {
    print("❌ Permisos denegados. No se puede escanear.");
    _isConnecting = false;
    return; // No continúes si faltan permisos
  }
  print("✅ Permisos concedidos.");
    if (FlutterBluePlus.isScanningNow || _isConnecting) {
      print("⚠️ Ya se está escaneando o conectando.");
      return;
    }

    print("🔎 Iniciando escaneo...");
    _isConnecting = true; 

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      BluetoothDevice? targetDevice;
      try {
        targetDevice = results.firstWhere(
          (r) => r.device.name == TARGET_DEVICE_NAME,
        ).device;
      } catch (e) {
        // No encontrado en este lote, espera al siguiente
        return;
      }

      if (targetDevice != null) {
        await FlutterBluePlus.stopScan();
        _scanSubscription?.cancel();
        
        print("✅ Dispositivo encontrado: ${targetDevice.name}");
        connectedDevice = targetDevice;

        try {
          await connectedDevice!.connect();
          print("✅ CONECTADO a ${connectedDevice!.name}");

          // 3. ¡AVISA A LA UI! (Conectado)
          _isConnected = true;
          notifyListeners();

          _listenToDisconnects();
          await _listenToData();

        } catch (e) {
          print("❌ ERROR AL CONECTAR: $e");
          connectedDevice = null;
          
          // 3. ¡AVISA A LA UI! (Error al conectar)
          _isConnected = false;
          notifyListeners();

        } finally {
          // Pase lo que pase, terminamos el intento de conexión
          _isConnecting = false;
        }
      }
    }, onError: (e) {
      print("❌ ERROR DE ESCANEO: $e");
      _isConnecting = false;
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  /// Escucha el estado de la conexión para detectar desconexiones
  void _listenToDisconnects() {
    connectedDevice?.state.listen((BluetoothDeviceState state) {
      if (state == BluetoothDeviceState.disconnected) {
        print("❌ DISPOSITIVO DESCONECTADO");
        connectedDevice = null;
        _dataSubscription?.cancel(); 
        
        // 4. ¡AVISA A LA UI! (Desconectado)
        _isConnected = false;
        notifyListeners();
      }
    } as void Function(BluetoothConnectionState event)?);
  }

  /// Descubre servicios y se suscribe a las características
  Future<void> _listenToData() async {
    if (connectedDevice == null) return;

    try {
      var services = await connectedDevice!.discoverServices();
      for (var service in services) {
        // TODO: Filtra por el UUID de tu servicio
        for (var characteristic in service.characteristics) {
          // TODO: Filtra por el UUID de tu característica
          
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            
            _dataSubscription = characteristic.value.listen((value) {
              final dataString = String.fromCharCodes(value);
              _processData(dataString);
            }, onError: (e) {
              print("❌ ERROR AL ESCUCHAR CARACTERÍSTICA: $e");
            });
            print("✅ Suscrito a la característica ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("❌ ERROR AL DESCUBRIR SERVICIOS: $e");
    }
  }

  /// Procesa de forma segura los datos recibidos
  void _processData(String data) {
    if (data.trim().isEmpty) {
      print("⚠️ Datos recibidos vacíos.");
      return;
    }

    try {
      final parts = data.split(',');
      if (parts.length < 3) {
        print("❌ Error de formato: Se esperaban 3 partes. Data: '$data'");
        return;
      }

      final steps = int.tryParse(parts[0].split(':')[1]);
      final hr = int.tryParse(parts[1].split(':')[1]);
      final activity = parts[2].split(':')[1];

      if (steps == null || hr == null) {
        print("❌ Error de formato: No se pudo convertir a número. Data: '$data'");
        return;
      }

      LocalDatabase.insertData(
        steps: steps,
        heartRate: hr,
        activityType: activity,
      );

      print("💾 Datos guardados: $steps pasos, $hr bpm, $activity");

    } catch (e) {
      print("❌ ERROR GENERAL AL PROCESAR: $e. Data: '$data'");
    }
  }

  /// Método público para desconectar
  void disconnect() {
    _scanSubscription?.cancel();
    _dataSubscription?.cancel();
    connectedDevice?.disconnect();
    connectedDevice = null;
    _isConnecting = false;

    // 5. ¡AVISA A LA UI! (Desconexión manual)
    if (_isConnected) {
      _isConnected = false;
      notifyListeners();
    }
    print("🔌 Desconectado manualmente.");
  }
}