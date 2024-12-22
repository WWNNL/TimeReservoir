import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ArticleData {
  static final ArticleData _instance = ArticleData._internal();

  factory ArticleData() => _instance;
  static Database? _database;
  static const int databaseVersion = 1;

  ArticleData._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 初始化操作
    // 初始化 sqflite_ffi
    sqfliteFfiInit();
    // 设置数据库工厂为 sqflite_ffi
    databaseFactory = databaseFactoryFfi;

    String path = join(await getDatabasesPath(), 'article_data.db');
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ArticleData (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time TEXT,
      text TEXT,
      url TEXT
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("版本号为$oldVersion");
    if (oldVersion < 1) {
      // 更新数据库的操作
    }
  }

// 查看表的数据
  Future<List<Map<String, dynamic>>> getItemsFromTable() async {
    Database db = await database;
    return await db.query("ArticleData");
  }

// 查看存在某一条数据
  Future<bool> checkIfQrExists(String field,String value, {String tableName = "ArticleData"}) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$field= ?',
      whereArgs: [value],
    );
    return results.isNotEmpty;
  }

// 增加一条数据
  Future<void> insertRecord(Map<String, dynamic> data, {String tableName = "ArticleData"}) async {
    Database db = await database;
    await db.insert(tableName, data);
  }

// 更新一条数据
  Future<void> updateRecord(Map<String, dynamic> data,
      String field, String value, {String tableName = "ArticleData"}) async {
    Database db = await database;
    await db.update(
      tableName,
      data,
      where: '$field = ?',
      whereArgs: [value],
    );
  }

// 删除一条数据
  Future<void> deleteRecord(String field,
      String value, {String tableName = "ArticleData"}) async {
    Database db = await database;
    await db.delete(tableName, where: '$field = ?', whereArgs: [value]);
  }

}