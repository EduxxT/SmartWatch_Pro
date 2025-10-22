import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- AJUSTA ESTAS RUTAS SEGÚN TU PROYECTO ---
import '../modules/database/local_database.dart'; 
import '../modules/bluetooth/bluetooth_service.dart'; 
import 'screens/dashboard_screen.dart'; 
// ---------------------------------------------

void main() async { // 1. Añade 'async'
  // 2. Asegura que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized(); 

  // 3. Llama a tu nueva función de prueba
  print("--- INICIANDO PRUEBA DE BASE DE DATOS ---");
  await LocalDatabase.testConnection();
  print("--- PRUEBA DE BASE DE DATOS TERMINADA ---");

  // 4. El resto de tu app
  runApp(
    ChangeNotifierProvider(
      create: (context) => BluetoothService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartwatch App',
      // Asumo que tienes tus temas definidos en algún lugar
      // theme: ThemeData.light(), 
      // darkTheme: ThemeData.dark(),
      home: DashboardScreen(), // Tu pantalla principal
    );
  }
}