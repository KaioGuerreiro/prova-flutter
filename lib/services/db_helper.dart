import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/vehicle.dart';
import '../models/refuel.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'prova_flutter.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        plate TEXT NOT NULL,
        km INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE refuels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        liters REAL NOT NULL,
        price REAL NOT NULL,
        km INTEGER NOT NULL,
        FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');
  }

  // Vehicle CRUD
  Future<int> insertVehicle(Vehicle v) async {
    final database = await db;
    return await database.insert('vehicles', v.toMap());
  }

  Future<List<Vehicle>> getVehicles() async {
    final database = await db;
    final res = await database.query('vehicles', orderBy: 'id DESC');
    return res.map((m) => Vehicle.fromMap(m)).toList();
  }

  Future<int> updateVehicle(Vehicle v) async {
    final database = await db;
    return await database.update(
      'vehicles',
      v.toMap(),
      where: 'id = ?',
      whereArgs: [v.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final database = await db;
    return await database.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // Refuel CRUD
  Future<int> insertRefuel(Refuel r) async {
    final database = await db;
    return await database.insert('refuels', r.toMap());
  }

  Future<List<Refuel>> getRefuelsForVehicle(int vehicleId) async {
    final database = await db;
    final res = await database.query(
      'refuels',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return res.map((m) => Refuel.fromMap(m)).toList();
  }

  Future<int> updateRefuel(Refuel r) async {
    final database = await db;
    return await database.update(
      'refuels',
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<int> deleteRefuel(int id) async {
    final database = await db;
    return await database.delete('refuels', where: 'id = ?', whereArgs: [id]);
  }
}
