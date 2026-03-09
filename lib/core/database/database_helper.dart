import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/word_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vocab_flow.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  english TEXT NOT NULL,
  turkish TEXT NOT NULL,
  level_score INTEGER NOT NULL,
  ai_sentence TEXT NOT NULL,
  ai_sentence_tr TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
  }

  Future<int> insertWord(Word word) async {
    final db = await instance.database;
    return await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final result = await db.query('words', orderBy: 'created_at DESC');
    return result.map((json) => Word.fromMap(json)).toList();
  }

  Future<int> updateWord(Word word) async {
    final db = await instance.database;
    return db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await instance.database;
    return await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
