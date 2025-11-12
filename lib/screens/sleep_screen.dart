import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/sleep_header_card.dart';
import '../widgets/goal_quality_card.dart';
import '../widgets/week_days_graph.dart';
import '../widgets/last_sleep_card.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double goalHours = 8.0;

  // Datos semanales simulados (ejemplo)
  List<Map<String, dynamic>> sleepData = [
    {'day': 'M', 'hours': 7.5},
    {'day': 'T', 'hours': 8.0},
    {'day': 'W', 'hours': 8.2},
    {'day': 'T', 'hours': 7.8},
    {'day': 'F', 'hours': 8.5},
    {'day': 'S', 'hours': 6.9},
    {'day': 'S', 'hours': 8.0},
  ];

  int strikeCount = 0;

  @override
  void initState() {
    super.initState();
    _calculateStrike();
  }

  void _calculateStrike() {
    int streak = 0;
    for (var day in sleepData) {
      if (day['hours'] >= goalHours) {
        streak++;
      } else {
        streak = 0; // rompe la racha
      }
    }
    setState(() => strikeCount = streak);
  }

 void _setGoalDialog() async {
  double tempGoal = goalHours;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: kDarkSecondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Set your sleep goal',
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
                  '${tempGoal.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: tempGoal,
                  min: 4,
                  max: 10,
                  divisions: 12,
                  activeColor: kAccentColor,
                  inactiveColor: Colors.white24,
                  label: '${tempGoal.toStringAsFixed(1)}h',
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
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
                goalHours = tempGoal;
                _calculateStrike();
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


  @override
  Widget build(BuildContext context) {
    const double screenPadding = 20.0;
    const double cardSpacing = 20.0;

    // Convertir datos para la gráfica
    final graphData = sleepData
        .map((d) => {
              'day': d['day'],
              'hours': '${d['hours']}h',
              'factor': (d['hours'] / goalHours).clamp(0.0, 1.2)
            })
        .toList();

    final lastNight = sleepData.last;

    return Scaffold(
      backgroundColor: kDarkPrimaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: screenPadding,
        title: Text('Mi sueño 🌚', style: h1Style),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Encabezado con Strike
            SleepHeaderCard(
              currentHours: lastNight['hours'],
              goalHours: goalHours,
              strikeCount: strikeCount,
              isActivityView: false,
            ),

            const SizedBox(height: cardSpacing),

            // 2. Meta y Calidad
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _setGoalDialog,
                    child: GoalQualityCard(
                      title: 'Set Goal',
                      subtitle: '${goalHours.toStringAsFixed(1)}h',
                      backgroundColor: kAccentColor,
                      titleColor: kDarkPrimaryText,
                    ),
                  ),
                ),
                const SizedBox(width: cardSpacing),
                const Expanded(
                  child: GoalQualityCard(
                    title: 'Quality',
                    subtitle: 'Last night',
                    backgroundColor: kDarkSecondaryBackground,
                    titleColor: kDarkPrimaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: cardSpacing),

            // 3. Gráfica semanal
            WeekDaysGraph(sleepData: graphData),

            const SizedBox(height: cardSpacing),

            // 4. Última sesión de sueño
            LastSleepCard(
              duration: '${lastNight['hours']} H',
              timeRange: '12:00 AM - 8:00 AM',
              hintText: 'Try to sleep earlier tonight 😴',
            ),
          ],
        ),
      ),
    );
  }
}
