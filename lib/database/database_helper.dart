import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/face_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('faces.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE faces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imagePath TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertFace(FaceModel face) async {
    final db = await instance.database;
    return await db.insert('faces', face.toMap());
  }

  Future<List<FaceModel>> getAllFaces() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('faces');
    return maps.map((map) => FaceModel.fromMap(map)).toList();
  }

  Future<int> deleteFace(int id) async {
    final db = await instance.database;
    return await db.delete('faces', where: 'id = ?', whereArgs: [id]);
  }
}
