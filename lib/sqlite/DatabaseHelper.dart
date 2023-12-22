import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'User.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        location TEXT
      )
    ''');
  }

  Future<int> insertUser(String name, String location) async {
    Database db = await database;
    return await db.rawInsert(
        'INSERT INTO users (name, location) VALUES (?, ?)',
        [name, location]);
  }

  Future<List<User>> getUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (index) {
      return User(
        id: maps[index]['id'],
        name: maps[index]['name'],
        location: maps[index]['location'],
      );
    });
  }

  Future<int?> countUsers() async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
  }
}
