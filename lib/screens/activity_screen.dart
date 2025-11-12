import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modules/bluetooth/bluetooth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/sleep_header_card.dart';
import '../widgets/goal_quality_card.dart';
import '../widgets/week_days_graph.dart';
import '../widgets/dashboard_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const int goalSteps = 5000; // Meta diaria
  List<Map<String, dynamic>> weeklyData = []; // Datos semanales de pasos
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
  }

  void _initializeWeek() {
    // Crear 7 días vacíos
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    weeklyData = List.generate(
      7,
      (i) => {
        'day': days[i],
        'steps': 0,
        'factor': 0.0,
      },
    );
  }

  void _updateWeekData(int newSteps) {
    final today = DateTime.now().weekday - 1; // 0 = Lunes
    weeklyData[today]['steps'] = newSteps;
    weeklyData[today]['factor'] =
        (newSteps / goalSteps).clamp(0.0, 1.0); // Factor 0–1
    _calculateStreak();
  }

  void _calculateStreak() {
    int newStreak = 0;
    for (var d in weeklyData) {
      if ((d['steps'] as int) >= goalSteps) {
        newStreak++;
      } else {
        newStreak = 0;
      }
    }
    setState(() {
      streak = newStreak;
    });
  }

  Widget _buildGraphLabels(int steps, double distanceKm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Steps', style: textStyle.copyWith(color: kDarkSecondaryText)),
                Text('$steps', style: titleStyle.copyWith(color: kDarkPrimaryText)),
                Text('Today', style: textStyle.copyWith(color: kDarkSecondaryText)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distance', style: textStyle.copyWith(color: kDarkSecondaryText)),
                Text('${distanceKm.toStringAsFixed(2)} km',
                    style: titleStyle.copyWith(color: kDarkPrimaryText)),
                Text('Goal: $goalSteps', style: textStyle.copyWith(color: kDarkSecondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double screenPadding = 20.0;
    const double cardSpacing = 20.0;

    return Consumer<BluetoothProvider>(
  builder: (context, ble, _) {
    // ✅ Ejecutar después del build actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateWeekData(ble.steps);
    });

        return Scaffold(
          backgroundColor: kDarkPrimaryBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: screenPadding,
            title: Text('My Activity', style: h1Style),
            toolbarHeight: 80,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(screenPadding),
            child: Column(
              children: [
                // 1️⃣ Encabezado circular
                SleepHeaderCard(
                  currentHours: ble.steps.toDouble(),
                  goalHours: goalSteps.toDouble(),
                  metricLabel: "Steps",
                ),

                const SizedBox(height: cardSpacing),

                // 2️⃣ Gráfica semanal
                WeekDaysGraph(
                  sleepData: weeklyData
                      .map((d) => {
                            'day': d['day'],
                            'factor': d['factor'],
                            'hours': '${d['steps']}',
                          })
                      .toList(),
                ),

                const SizedBox(height: 10),

                // 3️⃣ Etiquetas debajo de la gráfica
                _buildGraphLabels(ble.steps, ble.distanceKm),

                const SizedBox(height: cardSpacing),

                // 4️⃣ Tarjetas: Meta y Racha
                Row(
                  children: [
                    Expanded(
                      child: GoalQualityCard(
                        title: 'Set Goal',
                        subtitle: '$goalSteps',
                        backgroundColor: kAccentColor,
                        titleColor: kDarkPrimaryText,
                      ),
                    ),
                    const SizedBox(width: cardSpacing),
                    Expanded(
                      child: GoalQualityCard(
                        title: 'Streak',
                        subtitle: '$streak days',
                        backgroundColor: kDarkSecondaryBackground,
                        titleColor: kDarkPrimaryText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: cardSpacing),

                // 5️⃣ Tarjeta motivacional
                DashboardCard(
                  title: "Let's Move!",
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ble.steps >= goalSteps
                            ? '🔥 Great job! You hit your goal today.'
                            : 'Keep it up! You\'re getting closer!',
                        style: textStyle.copyWith(color: kDarkSecondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
