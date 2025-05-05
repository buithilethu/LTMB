import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper _instance = NoteDatabaseHelper._internal();
  static Database? _database;

  factory NoteDatabaseHelper() => _instance;

  NoteDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE notes ADD COLUMN userId INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  Future<Note?> getNoteById(int id, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [note.id, note.userId],
    );
  }

  Future<int> deleteNote(int id, int userId) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<Note>> getNotesByPriority(int priority, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'priority = ? AND userId = ?',
      whereArgs: [priority, userId],
    );
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  Future<List<Note>> searchNotes(String query, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'userId = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
    );
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
