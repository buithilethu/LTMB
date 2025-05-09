import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

// Màn hình hiển thị danh sách công việc
class TaskListScreen extends StatefulWidget {
  final User currentUser; // Người dùng hiện tại (để lọc công việc và kiểm tra quyền)

  TaskListScreen({required this.currentUser});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

// Lớp state của TaskListScreen, quản lý trạng thái giao diện
class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController(); // Controller cho ô tìm kiếm
  String? _selectedStatus; // Trạng thái được chọn để lọc
  int? _selectedPriority; // Độ ưu tiên được chọn để lọc
  bool _isKanbanView = false; // Chế độ hiển thị: danh sách (false) hoặc Kanban (true)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold cung cấp cấu trúc giao diện cơ bản
      appBar: AppBar(
        title: const Text('Danh Sách Công Việc'),
        backgroundColor: Colors.blue.shade700, // Màu nền thanh ứng dụng
        foregroundColor: Colors.white, // Màu chữ/icon
        elevation: 0, // Không đổ bóng
        actions: [
          // Nút chuyển đổi chế độ hiển thị (danh sách/Kanban)
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column, color: Colors.white),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView; // Chuyển đổi chế độ
              });
            },
            tooltip: _isKanbanView ? 'Chuyển sang chế độ danh sách' : 'Chuyển sang chế độ Kanban',
          ),
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Quay lại màn hình đăng nhập và xóa toàn bộ stack điều hướng
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Container(
        // Container với gradient nền từ xanh nhạt đến trắng
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Phần tìm kiếm và lọc
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2, // Độ nâng của card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bo góc
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Ô tìm kiếm
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm công việc',
                          prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Cập nhật giao diện khi nhập tìm kiếm
                        },
                      ),
                      const SizedBox(height: 12),
                      // Bộ lọc trạng thái và độ ưu tiên
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true, // Chiếm toàn chiều rộng
                              value: _selectedStatus,
                              hint: const Text(
                                'Lọc theo trạng thái',
                                overflow: TextOverflow.ellipsis,
                              ),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Tất cả')),
                                DropdownMenuItem(value: 'To do', child: Text('Cần làm')),
                                DropdownMenuItem(value: 'In progress', child: Text('Đang tiến hành')),
                                DropdownMenuItem(value: 'Done', child: Text('Hoàn thành')),
                                DropdownMenuItem(value: 'Cancelled', child: Text('Đã hủy')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value; // Cập nhật trạng thái lọc
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: _selectedPriority,
                              hint: const Text(
                                'Lọc theo độ ưu tiên',
                                overflow: TextOverflow.ellipsis,
                              ),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Độ ưu tiên')),
                                DropdownMenuItem(value: 1, child: Text('Thấp')),
                                DropdownMenuItem(value: 2, child: Text('Trung bình')),
                                DropdownMenuItem(value: 3, child: Text('Cao')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value; // Cập nhật độ ưu tiên lọc
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Phần hiển thị danh sách công việc
            Expanded(
              child: FutureBuilder<List<Task>>(
                // Lấy danh sách công việc từ database với bộ lọc
                future: DatabaseHelper.instance.searchTasks(
                  widget.currentUser.id,
                  widget.currentUser.role,
                  query: _searchController.text,
                  status: _selectedStatus,
                  priority: _selectedPriority,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    // Hiển thị loading nếu dữ liệu chưa sẵn sàng
                    return Center(child: CircularProgressIndicator(color: Colors.blue.shade700));
                  }
                  final tasks = snapshot.data!;
                  // Chế độ Kanban
                  if (_isKanbanView) {
                    // Nhóm công việc theo trạng thái
                    final statusGroups = {
                      'To do': tasks.where((task) => task.status == 'To do').toList(),
                      'In progress': tasks.where((task) => task.status == 'In progress').toList(),
                      'Done': tasks.where((task) => task.status == 'Done').toList(),
                      'Cancelled': tasks.where((task) => task.status == 'Cancelled').toList(),
                    };
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Cuộn ngang
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: statusGroups.entries.map((entry) {
                          return Container(
                            width: 280, // Chiều rộng mỗi cột Kanban
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Tiêu đề cột (trạng thái)
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      {
                                        'To do': 'Cần làm',
                                        'In progress': 'Đang tiến hành',
                                        'Done': 'Hoàn thành',
                                        'Cancelled': 'Đã hủy',
                                      }[entry.key]!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1, color: Colors.blueGrey),
                                  // Danh sách công việc trong cột
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: entry.value.length,
                                      itemBuilder: (context, index) {
                                        final task = entry.value[index];
                                        return Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: TaskItem(
                                            task: task,
                                            onTap: () {
                                              // Chuyển đến màn hình chi tiết công việc
                                              Navigator.pushNamed(
                                                context,
                                                '/task_detail',
                                                arguments: {'user': widget.currentUser, 'task': task},
                                              ).then((value) {
                                                if (value == true) setState(() {}); // Làm mới nếu có thay đổi
                                              });
                                            },
                                            onDelete: () async {
                                              // Xóa công việc
                                              await DatabaseHelper.instance.deleteTask(task.id);
                                              setState(() {}); // Làm mới giao diện
                                            },
                                            onToggleComplete: () async {
                                              // Chuyển đổi trạng thái hoàn thành
                                              final updatedTask = Task(
                                                id: task.id,
                                                title: task.title,
                                                description: task.description,
                                                status: task.status,
                                                priority: task.priority,
                                                dueDate: task.dueDate,
                                                assignedTo: task.assignedTo,
                                                createdBy: task.createdBy,
                                                completed: !task.completed,
                                                createdAt: task.createdAt,
                                                updatedAt: DateTime.now(),
                                                category: task.category,
                                                attachments: task.attachments,
                                              );
                                              await DatabaseHelper.instance.updateTask(updatedTask);
                                              setState(() {}); // Làm mới giao diện
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    // Chế độ danh sách
                    return ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TaskItem(
                            task: task,
                            onTap: () {
                              // Chuyển đến màn hình chi tiết công việc
                              Navigator.pushNamed(
                                context,
                                '/task_detail',
                                arguments: {'user': widget.currentUser, 'task': task},
                              ).then((value) {
                                if (value == true) setState(() {}); // Làm mới nếu có thay đổi
                              });
                            },
                            onDelete: () async {
                              // Xóa công việc
                              await DatabaseHelper.instance.deleteTask(task.id);
                              setState(() {}); // Làm mới giao diện
                            },
                            onToggleComplete: () async {
                              // Chuyển đổi trạng thái hoàn thành
                              final updatedTask = Task(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                status: task.status,
                                priority: task.priority,
                                dueDate: task.dueDate,
                                assignedTo: task.assignedTo,
                                createdBy: task.createdBy,
                                completed: !task.completed,
                                createdAt: task.createdAt,
                                updatedAt: DateTime.now(),
                                category: task.category,
                                attachments: task.attachments,
                              );
                              await DatabaseHelper.instance.updateTask(updatedTask);
                              setState(() {}); // Làm mới giao diện
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // Nút nổi để thêm công việc mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển đến màn hình thêm công việc
          Navigator.pushNamed(
            context,
            '/task_form',
            arguments: {'user': widget.currentUser, 'task': null},
          ).then((value) {
            if (value == true) setState(() {}); // Làm mới nếu thêm thành công
          });
        },
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Thêm công việc mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}