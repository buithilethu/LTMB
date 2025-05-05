import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper _instance = NoteDatabaseHelper._internal();
  static Database? _database;

  factory NoteDatabaseHelper() => _instance;

  NoteDatabaseHelper._internal();

  // Khởi tạo hoặc lấy database đã có
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Tạo hoặc mở database
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn của database
    String path = join(await getDatabasesPath(), 'notes_database.db');

    // Mở hoặc tạo database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb, // Tạo bảng khi lần đầu tiên mở database
      onUpgrade: _onUpgrade, // Tùy chọn xử lý khi nâng cấp database
    );
  }

  // Tạo bảng dữ liệu khi lần đầu tiên mở database
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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

  // Tùy chọn nâng cấp database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Xử lý nâng cấp database tại đây (nếu có)
      // Ví dụ: ALTER TABLE hoặc các thay đổi schema khác
    }
  }

  // Thêm một ghi chú mới
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
    );
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  // Tìm kiếm ghi chú theo từ khóa
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) => Note.fromMap(maps[i]))
        : [];
  }

  // Đóng database (nếu cần)
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null; // Reset _database để mở lại khi cần thiết
  }
}
