import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartwatch_data.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activity_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        steps INTEGER,
        heart_rate INTEGER,
        activity_type TEXT
      )
    ''');
  }

  static Future<void> insertData({
    required int steps,
    required int heartRate,
    required String activityType,
  }) async {
    final db = await database;
    await db.insert('activity_data', {
      'timestamp': DateTime.now().toIso8601String(),
      'steps': steps,
      'heart_rate': heartRate,
      'activity_type': activityType,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('activity_data', orderBy: 'id DESC');
  }

  // --- FUNCIÓN DE PRUEBA AÑADIDA ---
  static Future<void> testConnection() async {
    print("🔌 Iniciando prueba de conexión BD (sqflite)...");
    try {
      // Paso 1: Inicializar (esto lo hace el getter 'database' automáticamente)
      print("  -> Obteniendo instancia de la base de datos...");
      final db = await database; 
      print("  -> Instancia de BD obtenida. (Path: ${db.path})");

      // Paso 2: Escribir un dato de prueba usando TU método
      print("  -> Escribiendo un registro de prueba...");
      await insertData(
        steps: 100,
        heartRate: 80,
        activityType: "test_walk"
      );
      print("  -> Escritura completada.");

      // Paso 3: Leer el dato de vuelta usando TU método
      print("  -> Leyendo todos los registros...");
      final List<Map<String, dynamic>> data = await getAllData();

      // Paso 4: Verificar
      if (data.isNotEmpty) {
        print("  -> ¡ÉXITO! Se encontraron ${data.length} registros.");
        // Imprimimos el primer registro (que es el último insertado por tu 'orderBy')
        print("  -> Último registro insertado: ${data.first}"); 
      } else {
        print("  -> ¡FALLO! No se encontraron registros después de insertar.");
      }

    } catch (e) {
      print("❌ ERROR DURANTE LA PRUEBA DE CONEXIÓN A BD: $e");
    }
  }
}