// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/sensor_data_model.dart';

// class SensorLocalDb {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDb();
//     return _db!;
//   }

//   static Future<Database> _initDb() async {
//     final dbPath = await getDatabasesPath();
//     return openDatabase(
//       join(dbPath, 'greengrow_sensor.db'),
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE sensor_data(
//             id INTEGER PRIMARY KEY,
//             temperature REAL,
//             humidity REAL,
//             status TEXT,
//             recorded_at TEXT
//           )
//         ''');
//       },
//     );
//   }

//   static Future<void> insertSensorData(SensorDataModel data) async {
//     final db = await database;
//     await db.insert(
//       'sensor_data',
//       {
//         'id': data.id,
//         'temperature': data.temp,
//         'humidity': data.humidity,
//         'status': data.status,
//         'recorded_at': data.recordedAt.toIso8601String(),
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   static Future<List<SensorDataModel>> getAllSensorData() async {
//     final db = await database;
//     final maps = await db.query('sensor_data', orderBy: 'recorded_at DESC');
//     return maps.map((e) => SensorDataModel(
//       id: e['id'] as int,
//       temp: (e['temperature'] as num).toDouble(),
//       humidity: (e['humidity'] as num).toDouble(),
//       status: e['status'] as String,
//       recordedAt: DateTime.parse(e['recorded_at'] as String),
//     )).toList();
//   }
// } 