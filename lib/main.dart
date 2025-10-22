// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen_manager.dart'; // Importamos el nuevo Manager
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wearable Dashboard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kDarkPrimaryBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // CAMBIO CLAVE: Iniciamos con el Manager
      home: const HomeScreenManager(),
    );
  }
}