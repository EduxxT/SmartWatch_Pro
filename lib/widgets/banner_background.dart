import 'package:flutter/material.dart';
import 'dart:async';

class BannerConFondoHora extends StatefulWidget {
  const BannerConFondoHora({super.key});

  @override
  State<BannerConFondoHora> createState() => _BannerConFondoHoraState();
}

class _BannerConFondoHoraState extends State<BannerConFondoHora> {
  late String _horaActual;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _horaActual = _obtenerHora();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _horaActual = _obtenerHora();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _obtenerHora() {
    final ahora = DateTime.now();
    return "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";
  }

  String _fondoSegunHora() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) {
      return 'assets/images/fondo_sol.png'; // 🌤 Mañana
    } else if (hora >= 12 && hora < 18) {
      return 'assets/images/fondo_tarde.png'; // 🌇 Tarde
    } else {
      return 'assets/images/fondo_luna.png'; // 🌙 Noche
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(_fondoSegunHora()),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 15,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _horaActual,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
