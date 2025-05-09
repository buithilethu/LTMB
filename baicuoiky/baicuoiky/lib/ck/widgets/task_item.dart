import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

// Widget hiển thị một công việc trong danh sách
class TaskItem extends StatelessWidget {
  final Task task; // Công việc cần hiển thị
  final VoidCallback onTap; // Hàm gọi khi nhấn vào công việc
  final VoidCallback onDelete; // Hàm gọi khi nhấn nút xóa
  final VoidCallback onToggleComplete; // Hàm gọi khi nhấn nút chuyển đổi trạng thái hoàn thành

  TaskItem({
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onToggleComplete,
  });

  // Ánh xạ trạng thái tiếng Anh (lưu trữ) sang tiếng Việt (hiển thị)
  final Map<String, String> _statusDisplayMap = {
    'To do': 'Cần làm',
    'In progress': 'Đang tiến hành',
    'Done': 'Đã hoàn thành',
    'Cancelled': 'Đã hủy',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card tạo hiệu ứng nổi cho công việc
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Khoảng cách xung quanh
      child: ListTile(
        // ListTile để hiển thị nội dung công việc
        title: Text(
          task.title, // Tiêu đề công việc
          style: TextStyle(
            // Nếu công việc hoàn thành, gạch ngang tiêu đề
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          // Hiển thị các thông tin phụ theo cột
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description), // Mô tả công việc
            Text('Trạng thái: ${_statusDisplayMap[task.status] ?? task.status}'), // Trạng thái (dịch sang tiếng Việt)
            // Hiển thị hạn hoàn thành nếu có
            if (task.dueDate != null)
              Text('Hạn: ${DateFormat.yMd().format(task.dueDate!)}'), // Định dạng ngày
            // Hiển thị danh mục nếu có
            if (task.category != null) Text('Danh mục: ${task.category}'),
          ],
        ),
        trailing: Row(
          // Các nút hành động bên phải
          mainAxisSize: MainAxisSize.min, // Thu gọn chiều rộng
          children: [
            // Hiển thị biểu tượng ưu tiên
            if (task.priority == 3)
              Icon(Icons.warning, color: Colors.red), // Ưu tiên cao: biểu tượng đỏ
            if (task.priority == 2)
              Icon(Icons.warning, color: Colors.yellow), // Ưu tiên trung bình: biểu tượng vàng
            // Nút chuyển đổi trạng thái hoàn thành
            IconButton(
              icon: Icon(
                task.completed ? Icons.check_circle : Icons.check_circle_outline,
                color: task.completed ? Colors.green : null, // Màu xanh nếu hoàn thành
              ),
              onPressed: onToggleComplete, // Gọi hàm chuyển đổi trạng thái
            ),
            // Nút xóa công việc
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete, // Gọi hàm xóa
            ),
          ],
        ),
        onTap: onTap, // Nhấn vào công việc để xem chi tiết
      ),
    );
  }
}