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
        "status" TEXT NOT NULL,
        "statusIconUrl" TEXT NOT NULL
      )
    ''');
    print("onCreate =====================================");
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

  Future<List<Map>> getPrayersByDate(String date) async {
    Database? mydb = await db;
    return await mydb!.rawQuery(
      'SELECT * FROM prayers WHERE date = ?',
      [date],
    );
  }

  Future<List<Map>> getPrayerStatistics() async {
    Database? mydb = await db;
    return await mydb!.rawQuery('''
      SELECT prayerName, status, COUNT(*) as count
      FROM prayers
      GROUP BY prayerName, status
    ''');
  }

  Future<int> getTotalPrayersCount() async {
    Database? mydb = await db;
    var result = await mydb!.rawQuery('SELECT COUNT(*) as count FROM prayers');
    return result.first['count'] as int;
  }
}