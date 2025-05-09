import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/user.dart';

// Lớp TaskDetailScreen là một StatefulWidget, dùng để hiển thị chi tiết một công việc
class TaskDetailScreen extends StatefulWidget {
  final Task task; // Công việc cần hiển thị chi tiết
  final User currentUser; // Người dùng hiện tại (để kiểm tra quyền hoặc hiển thị)

  TaskDetailScreen({required this.task, required this.currentUser});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

// Lớp state của TaskDetailScreen, quản lý trạng thái giao diện
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _currentStatus; // Trạng thái hiện tại của công việc
  bool _isUpdating = false; // Biến trạng thái để hiển thị loading khi cập nhật

  // Map để ánh xạ trạng thái tiếng Anh sang tiếng Việt để hiển thị
  final Map<String, String> _statusDisplayMap = {
    'To do': 'Cần làm',
    'In progress': 'Đang tiến hành',
    'Done': 'Đã hoàn thành',
    'Cancelled': 'Đã hủy',
  };

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái ban đầu từ công việc được truyền vào
    _currentStatus = widget.task.status;
  }

  // Hàm cập nhật trạng thái công việc
  Future<void> _updateStatus(String newStatus) async {
    // Nếu trạng thái mới giống trạng thái hiện tại, không làm gì
    if (newStatus == _currentStatus) return;

    // Bật trạng thái loading
    setState(() {
      _isUpdating = true;
    });

    try {
      // Tạo đối tượng Task mới với trạng thái đã thay đổi
      final updatedTask = Task(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        status: newStatus,
        priority: widget.task.priority,
        dueDate: widget.task.dueDate,
        assignedTo: widget.task.assignedTo,
        createdBy: widget.task.createdBy,
        completed: widget.task.completed,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(), // Cập nhật thời gian mới
        category: widget.task.category,
        attachments: widget.task.attachments,
      );

      // Lưu công việc đã cập nhật vào database
      await DatabaseHelper.instance.updateTask(updatedTask);
      // Cập nhật trạng thái giao diện
      setState(() {
        _currentStatus = newStatus;
      });
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
      // Quay lại màn hình trước (TaskListScreen) và báo hiệu cần làm mới danh sách
      Navigator.pop(context, true);
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    } finally {
      // Tắt trạng thái loading
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold cung cấp cấu trúc cơ bản cho giao diện
      appBar: AppBar(
        title: const Text('Chi Tiết Công Việc'),
        backgroundColor: Colors.blue.shade700, // Màu nền thanh ứng dụng
        foregroundColor: Colors.white, // Màu chữ/icon
        elevation: 0, // Không đổ bóng
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
        child: SingleChildScrollView(
          // Cho phép cuộn nội dung nếu nội dung dài hơn màn hình
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card hiển thị tiêu đề và mô tả công việc
              Card(
                elevation: 2, // Độ nâng của card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bo góc
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card hiển thị trạng thái công việc
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng Thái',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _isUpdating
                                ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                                : DropdownButtonFormField<String>(
                              // Dropdown để chọn trạng thái
                              isExpanded: true, // Chiếm toàn chiều rộng
                              value: _currentStatus, // Giá trị hiện tại
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100, // Màu nền nhạt
                              ),
                              items: _statusDisplayMap.keys
                                  .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(_statusDisplayMap[status]!), // Hiển thị tiếng Việt
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _updateStatus(value); // Cập nhật trạng thái
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card hiển thị các chi tiết khác của công việc
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi Tiết',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hiển thị độ ưu tiên
                      _buildDetailRow(
                        context,
                        'Độ ưu tiên',
                        widget.task.priority == 1
                            ? 'Thấp'
                            : widget.task.priority == 2
                            ? 'Trung bình'
                            : 'Cao',
                      ),
                      // Hiển thị hạn hoàn thành nếu có
                      if (widget.task.dueDate != null)
                        _buildDetailRow(
                          context,
                          'Hạn hoàn thành',
                          DateFormat.yMd().format(widget.task.dueDate!), // Định dạng ngày
                        ),
                      // Hiển thị danh mục nếu có
                      if (widget.task.category != null)
                        _buildDetailRow(
                          context,
                          'Danh mục',
                          widget.task.category!,
                        ),
                      // Hiển thị thông tin người tạo (lấy từ database)
                      FutureBuilder<User?>(
                        future: DatabaseHelper.instance.getUserById(widget.task.createdBy),
                        builder: (context, snapshot) {
                          return _buildDetailRow(
                            context,
                            'Người tạo',
                            snapshot.hasData ? snapshot.data!.username : 'Không xác định',
                          );
                        },
                      ),
                      // Hiển thị thông tin người được gán (nếu có)
                      if (widget.task.assignedTo != null)
                        FutureBuilder<User?>(
                          future: DatabaseHelper.instance.getUserById(widget.task.assignedTo!),
                          builder: (context, snapshot) {
                            return _buildDetailRow(
                              context,
                              'Gán cho',
                              snapshot.hasData ? snapshot.data!.username : 'Không xác định',
                            );
                          },
                        ),
                      // Hiển thị thời gian tạo
                      _buildDetailRow(
                        context,
                        'Thời gian tạo',
                        DateFormat.yMd().add_Hms().format(widget.task.createdAt), // Định dạng ngày giờ
                      ),
                      // Hiển thị thời gian cập nhật
                      _buildDetailRow(
                        context,
                        'Cập nhật lần cuối',
                        DateFormat.yMd().add_Hms().format(widget.task.updatedAt),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card hiển thị danh sách tệp đính kèm
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đính Kèm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hiển thị danh sách tệp đính kèm nếu có
                      if (widget.task.attachments != null && widget.task.attachments!.isNotEmpty)
                        ...widget.task.attachments!
                            .map((attachment) => ListTile(
                          leading: Icon(Icons.attachment, color: Colors.blue.shade700),
                          title: Text(
                            attachment,
                            style: TextStyle(color: Colors.blue.shade700),
                            overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
                          ),
                          onTap: () {
                            // Hiển thị thông báo khi nhấn vào tệp (chưa xử lý mở tệp)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Mở link: $attachment')),
                            );
                          },
                        ))
                            .toList()
                      else
                        const Text('Không có tệp đính kèm'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Nút nổi để chỉnh sửa công việc
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển đến màn hình chỉnh sửa công việc
          Navigator.pushNamed(
            context,
            '/task_form',
            arguments: {'user': widget.currentUser, 'task': widget.task},
          ).then((value) {
            // Nếu chỉnh sửa thành công (value == true), quay lại và yêu cầu làm mới
            if (value == true) {
              Navigator.pop(context, true); // Refresh TaskListScreen
            }
          });
        },
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Chỉnh sửa công việc',
        child: const Icon(Icons.edit),
      ),
    );
  }

  // Hàm tạo hàng chi tiết (label-value) tái sử dụng
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}