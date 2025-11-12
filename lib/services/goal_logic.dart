// lib/services/goal_logic.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DayRecord {
  final DateTime date;
  final int steps;
  final int sleepMinutes; // minutos de sueño
  DayRecord({required this.date, required this.steps, required this.sleepMinutes});

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'steps': steps,
        'sleepMinutes': sleepMinutes,
      };

  static DayRecord fromMap(Map<String, dynamic> m) => DayRecord(
      date: DateTime.parse(m['date']), steps: m['steps'] ?? 0, sleepMinutes: m['sleepMinutes'] ?? 0);
}

class GoalManager {
  static const _keyGoalSteps = 'gw_goal_steps';
  static const _keyRecords = 'gw_day_records'; // map date->json

  final SharedPreferences prefs;

  GoalManager._(this.prefs);

  static Future<GoalManager> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return GoalManager._(prefs);
  }

  // ---------- Goal ----------
  int getGoalSteps() {
    return prefs.getInt(_keyGoalSteps) ?? 8000; // default
  }

  Future<bool> setGoalSteps(int steps) async {
    return prefs.setInt(_keyGoalSteps, steps);
  }

  // ---------- Records ----------
  Map<String, String> _rawRecordsMap() {
    // stored as map dateKey->jsonString in one prefs stringified map
    final raw = prefs.getString(_keyRecords);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(raw);
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveRawRecordsMap(Map<String, String> m) async {
    final encoded = json.encode(m);
    await prefs.setString(_keyRecords, encoded);
  }

  String _dateKey(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();

  Future<void> recordDay(DateTime date, {int? steps, int? sleepMinutes}) async {
    final map = _rawRecordsMap();
    final key = _dateKey(date);
    DayRecord r;
    if (map.containsKey(key)) {
      final existing = DayRecord.fromMap(json.decode(map[key]!));
      r = DayRecord(
        date: existing.date,
        steps: steps ?? existing.steps,
        sleepMinutes: sleepMinutes ?? existing.sleepMinutes,
      );
    } else {
      r = DayRecord(date: DateTime(date.year, date.month, date.day), steps: steps ?? 0, sleepMinutes: sleepMinutes ?? 0);
    }
    map[key] = json.encode(r.toMap());
    await _saveRawRecordsMap(map);
  }

  DayRecord getDay(DateTime date) {
    final map = _rawRecordsMap();
    final key = _dateKey(date);
    if (!map.containsKey(key)) {
      return DayRecord(date: DateTime(date.year, date.month, date.day), steps: 0, sleepMinutes: 0);
    }
    return DayRecord.fromMap(json.decode(map[key]!));
  }

  /// devuelve los N dias anteriores (incluyendo date) en orden ascendente (más antiguo -> más reciente)
  List<DayRecord> getLastNDays(DateTime date, int n) {
    final map = _rawRecordsMap();
    final List<DayRecord> out = [];
    for (int i = n - 1; i >= 0; i--) {
      final d = DateTime(date.year, date.month, date.day).subtract(Duration(days: i));
      final key = _dateKey(d);
      if (map.containsKey(key)) {
        out.add(DayRecord.fromMap(json.decode(map[key]!)));
      } else {
        out.add(DayRecord(date: d, steps: 0, sleepMinutes: 0));
      }
    }
    return out;
  }

  // ---------- Streak logic ----------
  /// calcula la racha actual (dias consecutivos terminando hoy) donde steps >= goal
  int currentStreak({DateTime? today}) {
    final g = getGoalSteps();
    final DateTime t = today == null ? DateTime.now() : DateTime(today.year, today.month, today.day);
    int streak = 0;
    DateTime cursor = t;
    while (true) {
      final DayRecord r = getDay(cursor);
      if (r.steps >= g) {
        streak += 1;
        cursor = cursor.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// calcula la racha mas larga en los ultimos `lookbackDays` dias
  int longestStreak({int lookbackDays = 365}) {
    final DateTime end = DateTime.now();
    int longest = 0;
    int current = 0;
    for (int i = lookbackDays - 1; i >= 0; i--) {
      final d = DateTime(end.year, end.month, end.day).subtract(Duration(days: i));
      final r = getDay(d);
      if (r.steps >= getGoalSteps()) {
        current += 1;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  // ---------- Weekly aggregates ----------
  /// devuelve 7 elementos (Lunes..Domingo opcional) a partir de weekStart:
  /// cada item = {'date': DateTime, 'steps': int, 'sleepMinutes': int}
  List<Map<String, dynamic>> weeklyAggregates(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final List<Map<String, dynamic>> out = [];
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final r = getDay(d);
      out.add({'date': d, 'steps': r.steps, 'sleepMinutes': r.sleepMinutes});
    }
    return out;
  }

  // util: devuelve arrays simples para graficas
  List<int> weeklyStepsAsList(DateTime weekStart) =>
      weeklyAggregates(weekStart).map((e) => (e['steps'] ?? 0) as int).toList();

  List<int> weeklySleepAsList(DateTime weekStart) =>
      weeklyAggregates(weekStart).map((e) => (e['sleepMinutes'] ?? 0) as int).toList();
}
