import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor_data_model.dart';

class SyncQueueDb {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'greengrow_sync_queue.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            temperature REAL,
            humidity REAL,
            status TEXT,
            recorded_at TEXT
          )
        ''');
      },
    );
  }

  static Future<void> addToQueue(SensorDataModel data) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      {
        'temperature': data.temperature,
        'humidity': data.humidity,
        'status': data.status,
        'recorded_at': data.recordedAt.toIso8601String(),
      },
    );
  }

  static Future<List<SensorDataModel>> getQueue() async {
    final db = await database;
    final maps = await db.query('sync_queue', orderBy: 'recorded_at ASC');
    return maps.map((e) => SensorDataModel(
      id: 0,
      temperature: (e['temperature'] as num).toDouble(),
      humidity: (e['humidity'] as num).toDouble(),
      status: e['status'] as String,
      recordedAt: DateTime.parse(e['recorded_at'] as String),
    )).toList();
  }

  static Future<void> clearQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }
} 