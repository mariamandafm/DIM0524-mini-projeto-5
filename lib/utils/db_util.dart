import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbUtil {
  static Future<sql.Database> openDatabaseConnection() async {
    final databasePath = await sql.getDatabasesPath();

    final pathToDatabase = path.join(databasePath, 'places.db');

    return sql.openDatabase(
      pathToDatabase,
      onCreate: (db, version) {
        //Se não estiver criado
        return db.execute(
            'CREATE TABLE places (id TEXT PRIMARY KEY, title TEXT, image TEXT)');
      },
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE places ADD COLUMN contact TEXT');
          db.execute('ALTER TABLE places ADD COLUMN email TEXT');
        }
        if (oldVersion < 3) {
          db.execute('ALTER TABLE places ADD COLUMN latitude REAL');
          db.execute('ALTER TABLE places ADD COLUMN longitude REAL');
          db.execute('ALTER TABLE places ADD COLUMN address TEXT');
        }
      },
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DbUtil.openDatabaseConnection();
    await db.insert(
      table,
      data,
      conflictAlgorithm: sql
          .ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbUtil.openDatabaseConnection();
    return db.query(table);
  }
}
