import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initializeDb();
      return _db;
    } else {
      return _db;
    }
  }

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
    return response;
  }

  // Insert a new prayer record
  Future<int> insertPrayer(String date, String prayerName, String prayerTime, String? status, String? statusIconUrl) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(
      'INSERT INTO prayers (date, prayerName, prayerTime, status, statusIconUrl) VALUES (?, ?, ?, ?, ?)',
      [date, prayerName, prayerTime, status, statusIconUrl],
    );
    return response;
  }

  // Update the status of a prayer for a specific date and prayer name
  Future<int> updatePrayerStatus(String date, String prayerName, String? status, String? statusIconUrl) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(
      'UPDATE prayers SET status = ?, statusIconUrl = ? WHERE date = ? AND prayerName = ?',
      [status, statusIconUrl, date, prayerName],
    );
    return response;
  }

  Future<List<Map>> readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}