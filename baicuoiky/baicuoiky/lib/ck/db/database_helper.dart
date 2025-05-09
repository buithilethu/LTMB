import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/task.dart';

// Lớp quản lý cơ sở dữ liệu SQLite
class DatabaseHelper {
  // Tạo một instance duy nhất của DatabaseHelper (singleton pattern)
  static final DatabaseHelper instance = DatabaseHelper._init();
  // Biến lưu trữ cơ sở dữ liệu
  static Database? _database;
  // Cache danh sách công việc để giảm truy vấn database
  static List<Task>? _taskCache;

  // Constructor riêng để khởi tạo instance
  DatabaseHelper._init();

  // Getter để lấy hoặc khởi tạo cơ sở dữ liệu
  Future<Database> get database async {
    // Nếu _database đã tồn tại, trả về nó
    if (_database != null) return _database!;
    // Nếu chưa, khởi tạo cơ sở dữ liệu và lưu vào _database
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  // Khởi tạo cơ sở dữ liệu và tạo file database
  Future<Database> _initDB(String fileName) async {
    // Lấy đường dẫn thư mục lưu trữ ứng dụng
    final dbPath = await getApplicationDocumentsDirectory();
    // Tạo đường dẫn đầy đủ cho file database
    final path = join(dbPath.path, fileName);
    // Mở hoặc tạo cơ sở dữ liệu tại đường dẫn
    return await openDatabase(
      path,
      version: 1, // Phiên bản database
      onCreate: _createDB, // Hàm tạo bảng khi database được tạo lần đầu
      onOpen: (db) async {
        // Bật hỗ trợ khóa ngoại (foreign key) để đảm bảo tính toàn vẹn dữ liệu
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  // Tạo các bảng trong cơ sở dữ liệu
  Future _createDB(Database db, int version) async {
    // Tạo bảng users để lưu thông tin người dùng
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY, -- Khóa chính, định danh duy nhất cho người dùng
        username TEXT NOT NULL, -- Tên đăng nhập, không được để trống
        password TEXT NOT NULL, -- Mật khẩu, không được để trống
        email TEXT NOT NULL, -- Email, không được để trống
        role TEXT NOT NULL, -- Vai trò (admin/user), không được để trống
        avatar TEXT, -- Đường dẫn ảnh đại diện, có thể để trống
        createdAt TEXT NOT NULL, -- Thời gian tạo tài khoản
        lastActive TEXT NOT NULL -- Thời gian hoạt động gần nhất
      )
    ''');

    // Tạo bảng tasks để lưu thông tin công việc
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY, -- Khóa chính, định danh duy nhất cho công việc
        title TEXT NOT NULL, -- Tiêu đề công việc
        description TEXT NOT NULL, -- Mô tả công việc
        status TEXT NOT NULL, -- Trạng thái (e.g., pending, completed)
        priority INTEGER NOT NULL, -- Độ ưu tiên (số nguyên)
        dueDate TEXT, -- Ngày hết hạn, có thể để trống
        assignedTo TEXT, -- ID người được giao việc, có thể để trống
        createdBy TEXT NOT NULL, -- ID người tạo công việc
        completed INTEGER NOT NULL, -- Trạng thái hoàn thành (0 hoặc 1)
        createdAt TEXT NOT NULL, -- Thời gian tạo công việc
        updatedAt TEXT NOT NULL, -- Thời gian cập nhật công việc
        category TEXT, -- Danh mục công việc, có thể để trống
        attachments TEXT, -- Đường dẫn tệp đính kèm, có thể để trống
        FOREIGN KEY (createdBy) REFERENCES users(id) ON DELETE NO ACTION, -- Khóa ngoại liên kết đến users(id)
        FOREIGN KEY (assignedTo) REFERENCES users(id) ON DELETE NO ACTION -- Khóa ngoại liên kết đến users(id)
      )
    ''');

    // Tạo index để tối ưu truy vấn theo assignedTo và status
    await db.execute('CREATE INDEX idx_tasks_assignedTo ON tasks(assignedTo)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');

    // Tạo tài khoản admin mặc định khi khởi tạo database
    await db.insert('users', {
      'id': 'admin1',
      'username': 'admin',
      'password': 'admin123', // Lưu ý: Mật khẩu nên được mã hóa trong thực tế
      'email': 'admin@example.com',
      'role': 'admin',
      'avatar': null,
      'createdAt': DateTime.now().toIso8601String(),
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  // Cập nhật thời gian hoạt động gần nhất của người dùng
  Future<void> updateLastActive(String userId) async {
    final db = await database;
    await db.update(
      'users',
      {'lastActive': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Thêm người dùng mới vào database
  Future<void> insertUser(User user) async {
    final db = await database;
    // Thêm hoặc thay thế nếu đã tồn tại (dựa trên id)
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Xóa người dùng theo id
  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy thông tin người dùng theo username
  Future<User?> getUser(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    // Nếu có kết quả, trả về User, ngược lại trả về null
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Lấy thông tin người dùng theo id
  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Lấy danh sách tất cả người dùng (dành cho admin)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('indexes');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Thêm công việc mới vào database
  Future<void> insertTask(Task task) async {
    final db = await database;
    // Kiểm tra xem người tạo công việc có tồn tại
    final creator = await getUserById(task.createdBy);
    if (creator == null) {
      throw Exception('Người tạo công việc không tồn tại: ${task.createdBy}');
    }
    // Kiểm tra xem người được gán công việc (nếu có) có tồn tại
    if (task.assignedTo != null) {
      final assignee = await getUserById(task.assignedTo!);
      if (assignee == null) {
        throw Exception('Người được gán công việc không tồn tại: ${task.assignedTo}');
      }
    }
    // Thêm công việc vào database
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _taskCache = null; // Xóa cache để đảm bảo dữ liệu mới được lấy
  }

  // Cập nhật thông tin công việc
  Future<void> updateTask(Task task) async {
    final db = await database;
    // Kiểm tra người tạo công việc
    final creator = await getUserById(task.createdBy);
    if (creator == null) {
      throw Exception('Người tạo công việc không tồn tại: ${task.createdBy}');
    }
    // Kiểm tra người được gán công việc (nếu có)
    if (task.assignedTo != null) {
      final assignee = await getUserById(task.assignedTo!);
      if (assignee == null) {
        throw Exception('Người được gán công việc không tồn tại: ${task.assignedTo}');
      }
    }
    // Cập nhật công việc
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _taskCache = null; // Xóa cache
  }

  // Xóa công việc theo id
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    _taskCache = null; // Xóa cache
  }

  // Lấy danh sách công việc theo vai trò người dùng
  Future<List<Task>> getTasks(String userId, String role) async {
    // Nếu cache tồn tại, trả về cache để giảm truy vấn
    if (_taskCache != null) return _taskCache!;
    final db = await database;
    List<Map<String, dynamic>> maps;
    // Admin có thể xem tất cả công việc
    if (role == 'admin') {
      maps = await db.query('tasks');
    } else {
      // Người dùng thường chỉ xem công việc được giao
      maps = await db.query('tasks', where: 'assignedTo = ?', whereArgs: [userId]);
    }
    // Chuyển kết quả thành danh sách Task và lưu vào cache
    _taskCache = maps.map((map) => Task.fromMap(map)).toList();
    return _taskCache!;
  }

  // Tìm kiếm và lọc công việc
  Future<List<Task>> searchTasks(
      String userId,
      String role, {
        String? query, // Từ khóa tìm kiếm
        String? status, // Trạng thái
        int? priority, // Độ ưu tiên
        DateTime? dueDateStart, // Ngày bắt đầu
        DateTime? dueDateEnd, // Ngày kết thúc
      }) async {
    final db = await database;
    // Khởi tạo điều kiện truy vấn
    String whereClause = role == 'admin' ? '' : 'assignedTo = ?';
    List<dynamic> whereArgs = role == 'admin' ? [] : [userId];

    // Thêm điều kiện tìm kiếm theo từ khóa
    if (query != null && query.isNotEmpty) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + '(title LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }
    // Thêm điều kiện lọc theo trạng thái
    if (status != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'status = ?';
      whereArgs.add(status);
    }
    // Thêm điều kiện lọc theo độ ưu tiên
    if (priority != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'priority = ?';
      whereArgs.add(priority);
    }
    // Thêm điều kiện lọc theo khoảng thời gian
    if (dueDateStart != null && dueDateEnd != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'dueDate BETWEEN ? AND ?';
      whereArgs.addAll([dueDateStart.toIso8601String(), dueDateEnd.toIso8601String()]);
    }

    // Thực hiện truy vấn
    final maps = await db.query('tasks', where: whereClause.isEmpty ? null : whereClause, whereArgs: whereArgs);
    // Lưu kết quả vào cache và trả về
    _taskCache = maps.map((map) => Task.fromMap(map)).toList();
    return _taskCache!;
  }
}