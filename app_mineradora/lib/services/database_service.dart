import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_mineradora/models/loading_record.dart';
import 'package:app_mineradora/models/unloading_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _db;

  DatabaseService._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mineradora.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Criar tabela para registros de carregamento (operador)
    await db.execute('''
      CREATE TABLE loading_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        data_trabalho TEXT NOT NULL,
        machine_id INTEGER NOT NULL,
        num_viagens INTEGER NOT NULL,
        tipo_caminhao TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Criar tabela para registros de saída (apontador)
    await db.execute('''
      CREATE TABLE unloading_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        data_saida TEXT NOT NULL,
        placa TEXT NOT NULL,
        metros_cubicos REAL NOT NULL,
        motorista TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Métodos para LoadingRecord
  Future<int> insertLoadingRecord(LoadingRecord record) async {
    final db = await database;
    return await db.insert('loading_records', record.toJson());
  }

  Future<List<LoadingRecord>> getUnsyncedLoadingRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loading_records',
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return LoadingRecord.fromJson(maps[i]);
    });
  }

  Future<void> markLoadingRecordAsSynced(int id) async {
    final db = await database;
    await db.update(
      'loading_records',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para UnloadingRecord
  Future<int> insertUnloadingRecord(UnloadingRecord record) async {
    final db = await database;
    return await db.insert('unloading_records', record.toJson());
  }

  Future<List<UnloadingRecord>> getUnsyncedUnloadingRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unloading_records',
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return UnloadingRecord.fromJson(maps[i]);
    });
  }

  Future<void> markUnloadingRecordAsSynced(int id) async {
    final db = await database;
    await db.update(
      'unloading_records',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para obter todos os registros (sincronizados e não sincronizados)
  Future<List<LoadingRecord>> getAllLoadingRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loading_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return LoadingRecord.fromJson(maps[i]);
    });
  }

  Future<List<UnloadingRecord>> getAllUnloadingRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unloading_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return UnloadingRecord.fromJson(maps[i]);
    });
  }
}