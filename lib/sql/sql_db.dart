import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class SqlDb {
  static Database? _db;
  static final StreamController<List<Map>> _prayersStreamController = StreamController.broadcast();

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initializeDb();
      return _db;
    } else {
      return _db;
    }
  }

  Stream<List<Map>> get prayersStream => _prayersStreamController.stream;

  _initializeDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'prayerDB.db');
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {
    print("onUpgrade =====================================");
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE "prayers" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "date" TEXT NOT NULL,
        "prayerName" TEXT NOT NULL,
        "prayerTime" TEXT NOT NULL,
        "status" TEXT,
        "statusIconUrl" TEXT
      )
    ''');
    print("onCreate =====================================");
  }

  // Fetch prayer data for a specific date
  Future<List<Map>> getPrayersByDate(String date) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
      'SELECT * FROM prayers WHERE date = ?',
      [date],
    );
    _notifyStream(); // Notify the stream after fetching data
    return response;
  }

  // Get count of prayers for a specific status and prayer name
  Future<int> getPrayerCountByStatus(String prayerName, String status) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
      'SELECT COUNT(*) as count FROM prayers WHERE prayerName = ? AND status = ?',
      [prayerName, status],
    );
    return response.isNotEmpty ? response[0]['count'] : 0;
  }

  // Get total count of all recorded prayers
  Future<int> getTotalPrayerCount() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('SELECT COUNT(*) as count FROM prayers');
    return response.isNotEmpty ? response[0]['count'] : 0;
  }

  // Get count of prayers for a specific status
  Future<int> getStatusCount(String status) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
      'SELECT COUNT(*) as count FROM prayers WHERE status = ?',
      [status],
    );
    return response.isNotEmpty ? response[0]['count'] : 0;
  }

  // Get count of prayers for a specific status within a date range
  Future<int> getStatusCountInRange(String status, DateTime startDate, DateTime endDate) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
      'SELECT COUNT(*) as count FROM prayers WHERE status = ? AND date BETWEEN ? AND ?',
      [status, startDate.toIso8601String().split('T')[0], endDate.toIso8601String().split('T')[0]],
    );
    return response.isNotEmpty ? response[0]['count'] : 0;
  }

  // Insert a new prayer record
  Future<int> insertPrayer(String date, String prayerName, String prayerTime, String? status, String? statusIconUrl) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(
      'INSERT INTO prayers (date, prayerName, prayerTime, status, statusIconUrl) VALUES (?, ?, ?, ?, ?)',
      [date, prayerName, prayerTime, status, statusIconUrl],
    );
    _notifyStream(); // Notify the stream after insertion
    return response;
  }

  // Update the status of a prayer for a specific date and prayer name
  Future<int> updatePrayerStatus(String date, String prayerName, String? status, String? statusIconUrl) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(
      'UPDATE prayers SET status = ?, statusIconUrl = ? WHERE date = ? AND prayerName = ?',
      [status, statusIconUrl, date, prayerName],
    );
    _notifyStream(); // Notify the stream after update
    return response;
  }

  // Notify the stream of changes
  void _notifyStream() async {
    Database? mydb = await db;
    List<Map> allPrayers = await mydb!.rawQuery('SELECT * FROM prayers');
    _prayersStreamController.add(allPrayers);
  }

  Future<List<Map>> readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    _notifyStream();
    return response;
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    _notifyStream();
    return response;
  }

  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    _notifyStream();
    return response;
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    _notifyStream();
    return response;
  }
}