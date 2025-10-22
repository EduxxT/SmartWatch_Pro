// lib/screens/home_screen_manager.dart (VERSIÓN SIN DESLIZAMIENTO)

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'sleep_screen.dart';
import 'activity_screen.dart'; // Importamos la nueva pantalla de Actividad
import '../utils/app_theme.dart'; 

class HomeScreenManager extends StatefulWidget {
  const HomeScreenManager({super.key});

  @override
  State<HomeScreenManager> createState() => _HomeScreenManagerState();
}

class _HomeScreenManagerState extends State<HomeScreenManager> {
  int _selectedIndex = 0; // Estado: 0 para Home, 1 para Sleep, 2 para Activity, etc.
  
  // Lista de todas las pantallas/vistas
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(), // 0: Home (Dashboard)
    const SleepScreen(),      // 1: Sleep
    const ActivityScreen(),  // 2: Activity <-- ¡Añadida la pantalla de Actividad!
    Center(child: Text('Health View', style: h1Style.copyWith(color: kDarkPrimaryText))),  // 3: Health
    Center(child: Text('Settings View', style: h1Style.copyWith(color: kDarkPrimaryText))),// 4: Settings
  ];

  // Función que se ejecuta al hacer clic en un ítem del NavBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // No hay lógica de PageController/animación aquí.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CUERPO: Usamos Center para mostrar el Widget correspondiente al índice
      body: Center(
        // Muestra la pantalla seleccionada actualmente
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // BARRA DE NAVEGACIÓN
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex, 
        onItemTapped: _onItemTapped,   
      ),
    );
  }
}