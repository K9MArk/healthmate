import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user_profile.dart';
import '../models/daily_record.dart';

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'healthmate.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        username TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        height_cm INTEGER NOT NULL,
        weight_kg REAL NOT NULL,
        has_diabetes INTEGER NOT NULL,
        has_cholesterol INTEGER NOT NULL,
        profile_picture TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_record (
        record_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        water_ml INTEGER NOT NULL,
        calorie_intake INTEGER NOT NULL,
        FOREIGN KEY (username) REFERENCES user_profile(username)
      )
    ''');
  }

  // -------- UserProfile CRUD --------

  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    return db.insert('user_profile', profile.toMap());
    // If you want to replace on conflict:
    // return db.insert('user_profile', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfile(String username) async {
    final db = await database;
    final res = await db.query(
      'user_profile',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return UserProfile.fromMap(res.first);
  }

  Future<UserProfile?> getAnyProfile() async {
    final db = await database;
    final res = await db.query('user_profile', limit: 1);
    if (res.isEmpty) return null;
    return UserProfile.fromMap(res.first);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return db.update(
      'user_profile',
      profile.toMap(),
      where: 'username = ?',
      whereArgs: [profile.username],
    );
  }

  // -------- DailyRecord CRUD --------

  Future<int> insertDailyRecord(DailyRecord record) async {
    final db = await database;
    return db.insert('daily_record', record.toMap());
  }

  Future<List<DailyRecord>> getDailyRecords(String username) async {
    final db = await database;
    final res = await db.query(
      'daily_record',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date DESC',
    );
    return res.map((e) => DailyRecord.fromMap(e)).toList();
  }

  Future<DailyRecord?> getRecordByDate(String username, String date) async {
    final db = await database;
    final res = await db.query(
      'daily_record',
      where: 'username = ? AND date = ?',
      whereArgs: [username, date],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return DailyRecord.fromMap(res.first);
  }

  Future<int> updateDailyRecord(DailyRecord record) async {
    final db = await database;
    return db.update(
      'daily_record',
      record.toMap(),
      where: 'record_id = ?',
      whereArgs: [record.recordId],
    );
  }

  Future<int> deleteDailyRecord(int id) async {
    final db = await database;
    return db.delete(
      'daily_record',
      where: 'record_id = ?',
      whereArgs: [id],
    );
  }
}
