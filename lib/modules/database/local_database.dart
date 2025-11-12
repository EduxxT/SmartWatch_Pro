import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartwatch.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // 👈 Aumenta versión si ya existe
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE activity_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    steps INTEGER,
    heart_rate INTEGER,
    distance REAL,
    goal INTEGER,
    activity_type TEXT
  )
''');


    // 🆕 Tabla para metas (pasos, sueño, etc.)
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_type TEXT UNIQUE,
        goal_value REAL
      )
    ''');
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_type TEXT UNIQUE,
          goal_value REAL
        )
      ''');
    }
  }

  // ==================================================
  // MÉTODOS PARA GUARDAR Y LEER DATOS DE METAS
  // ==================================================

  static Future<void> saveGoal(String goalType, double value) async {
    final db = await database;
    await db.insert(
      'goals',
      {'goal_type': goalType, 'goal_value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
// 💤 Guardar meta de sueño (en horas)
static Future<void> saveSleepGoal(double hours) async {
  final db = await database;
  await db.insert(
    'goals',
    {'goal_type': 'sleep', 'goal_value': hours},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// 💤 Obtener meta de sueño (en horas)
static Future<double> getSleepGoal() async {
  final db = await database;
  final result = await db.query(
    'goals',
    where: 'goal_type = ?',
    whereArgs: ['sleep'],
    limit: 1,
  );
  if (result.isNotEmpty) {
    return result.first['goal_value'] as double;
  } else {
    return 8.0; // valor por defecto
  }
}


  static Future<void> insertData({
  required int steps,
  required int heartRate,
  required double distance,
  required int goal,
  String activityType = 'walk',
}) async {
  final db = await database;

  await db.insert(
    'activity_data',
    {
      'timestamp': DateTime.now().toIso8601String(),
      'steps': steps,
      'heart_rate': heartRate,
      'activity_type': activityType,
      'distance': distance,
      'goal': goal,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  static Future<Map<String, dynamic>?> getLastRecord() async {
  final db = await database;

  // Asegúrate de tener una tabla llamada 'activity_data' o similar
  final result = await db.query(
    'activity_data',
    orderBy: 'timestamp DESC',
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}

  static Future<double?> getGoal(String goalType) async {
    final db = await database;
    final result = await db.query(
      'goals',
      where: 'goal_type = ?',
      whereArgs: [goalType],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['goal_value'] as double?;
    }
    return null;
  }

  // 🧪 (opcional) Verificar conexión
  static Future<void> testConnection() async {
    final db = await database;
    print("✅ SQLite conectado en: ${db.path}");
  }
}
