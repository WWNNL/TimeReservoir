import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String tableName = 'article';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'article_data.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        texts TEXT,
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert(tableName, student);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> update(int id, Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(tableName, student, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> query(String columnName, dynamic value) async {
    final db = await database;
    return await db.query(tableName, where: '$columnName = ?', whereArgs: [value]);
  }

  Future<List<Map<String, dynamic>>> queryScoreRange(String columnName, double lowerBound, double upperBound) async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$columnName BETWEEN ? AND ?',
      whereArgs: [lowerBound, upperBound],
    );
  }

}