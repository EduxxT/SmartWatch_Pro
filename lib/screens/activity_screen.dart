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
  double goalSteps = 5000; // Meta diaria inicial
  List<Map<String, dynamic>> weeklyData = [];
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
  }

  void _initializeWeek() {
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
    final today = DateTime.now().weekday - 1;
    weeklyData[today]['steps'] = newSteps;
    weeklyData[today]['factor'] = (newSteps / goalSteps).clamp(0.0, 1.0);
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

  // 🧠 Diálogo para ajustar meta de pasos
  void _setGoalDialog() async {
    double tempGoal = goalSteps;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kDarkSecondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Set your daily goal',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${tempGoal.toStringAsFixed(0)} steps',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: tempGoal,
                    min: 1000,
                    max: 15000,
                    divisions: 14,
                    activeColor: kAccentColor,
                    inactiveColor: Colors.white24,
                    label: '${tempGoal.toStringAsFixed(0)}',
                    onChanged: (value) {
                      setDialogState(() => tempGoal = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  goalSteps = tempGoal;
                  _calculateStreak();
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
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
                Text('Goal: ${goalSteps.toStringAsFixed(0)}',
                    style: textStyle.copyWith(color: kDarkSecondaryText)),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.flag, color: Colors.white),
                onPressed: _setGoalDialog, // 🧠 Ajustar meta
                tooltip: "Set goal",
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(screenPadding),
            child: Column(
              children: [
                // 1️⃣ Encabezado circular (muestra progreso actual)
                SleepHeaderCard(
                  currentHours: ble.steps.toDouble(),
  goalHours: goalSteps.toDouble(),
  metricLabel: "Steps",
  isActivityView: true,
  goalSteps: goalSteps.toDouble(),
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
                      child: GestureDetector(
                        onTap: _setGoalDialog, // 👈 También desde la tarjeta
                        child: GoalQualityCard(
                          title: 'Set Goal',
                          subtitle: '${goalSteps.toStringAsFixed(0)}',
                          backgroundColor: kAccentColor,
                          titleColor: kDarkPrimaryText,
                        ),
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
