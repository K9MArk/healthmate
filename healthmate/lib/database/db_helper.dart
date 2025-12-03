import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/record.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._privateConstructor();
  DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, 'healthmate.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');
  }

  // INSERT Record
  Future<int> insertRecord(Record record) async {
    final db = await database;
    return await db.insert(
      'health_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL records
  Future<List<Record>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Record.fromMap(maps[i]);
    });
  }

  // GET records by date (yyyy-MM-dd)
  Future<List<Record>> getRecordsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );

    return List.generate(maps.length, (i) {
      return Record.fromMap(maps[i]);
    });
  }

  // UPDATE record
  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // DELETE record
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }
}
