import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/task.dart';

// Màn hình thêm hoặc sửa công việc
class TaskFormScreen extends StatefulWidget {
  final Task? task; // Công việc cần chỉnh sửa (null nếu thêm mới)
  final User currentUser; // Người dùng hiện tại (để xác định quyền và gán công việc)

  TaskFormScreen({this.task, required this.currentUser});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

// Lớp state của TaskFormScreen, quản lý trạng thái giao diện
class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>(); // Key để quản lý form
  final _titleController = TextEditingController(); // Controller cho tiêu đề
  final _descriptionController = TextEditingController(); // Controller cho mô tả
  final _categoryController = TextEditingController(); // Controller cho danh mục
  final _attachmentController = TextEditingController(); // Controller cho link đính kèm
  String _status = 'To do'; // Trạng thái mặc định
  int _priority = 1; // Độ ưu tiên mặc định
  DateTime? _dueDate; // Ngày đến hạn
  String? _assignedTo; // ID người được gán công việc
  List<User> _users = []; // Danh sách người dùng (dành cho admin)
  List<String> _attachments = []; // Danh sách link đính kèm
  bool _isLoadingUsers = true; // Trạng thái loading khi lấy danh sách người dùng

  // Ánh xạ trạng thái tiếng Anh (lưu trữ) sang tiếng Việt (hiển thị)
  final Map<String, String> _statusDisplayMap = {
    'To do': 'Cần làm',
    'In progress': 'Đang tiến hành',
    'Done': 'Đã hoàn thành',
    'Cancelled': 'Đã hủy',
  };

  @override
  void initState() {
    super.initState();
    // Nếu đang chỉnh sửa công việc, điền sẵn dữ liệu từ task
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _categoryController.text = widget.task!.category ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _assignedTo = widget.task!.assignedTo;
      _attachments = widget.task!.attachments ?? [];
    } else {
      // Nếu thêm mới, gán người hiện tại làm người được gán và ngày hiện tại làm ngày đến hạn
      _assignedTo = widget.currentUser.id;
      _dueDate = DateTime.now();
    }

    // Nếu là admin, lấy danh sách người dùng để gán công việc
    if (widget.currentUser.role == 'admin') {
      DatabaseHelper.instance.getAllUsers().then((users) {
        setState(() {
          _users = users;
          _isLoadingUsers = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoadingUsers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy danh sách người dùng: $error')),
        );
      });
    } else {
      _isLoadingUsers = false; // Người dùng thường không cần tải danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading nếu đang tải danh sách người dùng
    if (_isLoadingUsers) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'Thêm công việc' : 'Sửa công việc'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.blue.shade700)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm công việc' : 'Sửa công việc'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // Cho phép cuộn nội dung
              child: Card(
                elevation: 2, // Độ nâng của card
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bo góc
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ô nhập tiêu đề
                      _buildTextField(_titleController, 'Tiêu đề', 'Vui lòng nhập tiêu đề'),
                      const SizedBox(height: 16),
                      // Ô nhập mô tả (nhiều dòng)
                      _buildTextField(_descriptionController, 'Mô tả', 'Vui lòng nhập mô tả', maxLines: 3),
                      const SizedBox(height: 16),
                      // Ô nhập danh mục (tùy chọn)
                      _buildTextField(_categoryController, 'Danh mục (tùy chọn)', null),
                      const SizedBox(height: 16),
                      // Dropdown chọn trạng thái
                      _buildDropdownField(
                        value: _status,
                        items: _statusDisplayMap.keys
                            .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusDisplayMap[status]!),
                        ))
                            .toList(),
                        label: 'Trạng thái',
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown chọn độ ưu tiên
                      _buildDropdownField(
                        value: _priority,
                        items: [
                          DropdownMenuItem(value: 1, child: Text('Thấp')),
                          DropdownMenuItem(value: 2, child: Text('Trung bình')),
                          DropdownMenuItem(value: 3, child: Text('Cao')),
                        ],
                        label: 'Độ ưu tiên',
                        onChanged: (value) => setState(() => _priority = value!),
                      ),
                      const SizedBox(height: 16),
                      // Widget chọn ngày đến hạn
                      _buildDatePicker(context),
                      const SizedBox(height: 16),
                      // Nếu là admin, hiển thị dropdown chọn người được gán
                      if (widget.currentUser.role == 'admin')
                        _users.isNotEmpty
                            ? _buildDropdownField(
                          value: _assignedTo,
                          items: _users
                              .map((user) => DropdownMenuItem(
                            value: user.id,
                            child: Text(user.username),
                          ))
                              .toList(),
                          label: 'Gán cho',
                          onChanged: (value) => setState(() => _assignedTo = value),
                        )
                            : Text('Không có người dùng nào để gán', style: TextStyle(color: Colors.red)),
                      // Nếu không phải admin, hiển thị tên người dùng hiện tại (không chỉnh sửa)
                      if (widget.currentUser.role != 'admin')
                        _buildTextField(
                          null,
                          'Gán cho',
                          null,
                          initialValue: widget.currentUser.username,
                          readOnly: true,
                        ),
                      const SizedBox(height: 16),
                      // Ô nhập link đính kèm
                      _buildAttachmentField(),
                      // Hiển thị danh sách link đính kèm
                      if (_attachments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Đính kèm',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        ..._attachments.asMap().entries.map((entry) => ListTile(
                          leading: Icon(Icons.attachment, color: Colors.blue.shade700),
                          title: Text(
                            entry.value,
                            style: TextStyle(color: Colors.blue.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _attachments.removeAt(entry.key)),
                          ),
                        )),
                      ],
                      const SizedBox(height: 24),
                      // Nút hành động (Thêm/Cập nhật và Hủy)
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm tạo ô nhập văn bản
  Widget _buildTextField(TextEditingController? controller, String label, String? validatorMessage,
      {int maxLines = 1, String? initialValue, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue, // Giá trị ban đầu nếu không dùng controller
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validatorMessage != null
          ? (value) => (value == null || value.isEmpty) ? validatorMessage : null
          : null, // Kiểm tra nếu bắt buộc
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }

  // Hàm tạo dropdown
  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required String label,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  // Hàm tạo widget chọn ngày
  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.grey.shade100,
      title: Text(
        _dueDate == null ? 'Chọn ngày đến hạn' : DateFormat.yMd().format(_dueDate!),
        style: TextStyle(color: _dueDate == null ? Colors.grey : Colors.black),
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.blue.shade700),
      onTap: () async {
        // Mở date picker
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null) setState(() => _dueDate = pickedDate);
      },
    );
  }

  // Hàm tạo ô nhập link đính kèm
  Widget _buildAttachmentField() {
    return TextFormField(
      controller: _attachmentController,
      decoration: InputDecoration(
        labelText: 'Link đính kèm (nhấn Thêm để lưu)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: IconButton(
          icon: Icon(Icons.add, color: Colors.blue.shade700),
          onPressed: () {
            // Thêm link vào danh sách và xóa ô nhập
            if (_attachmentController.text.isNotEmpty) {
              setState(() {
                _attachments.add(_attachmentController.text);
                _attachmentController.clear();
              });
            }
          },
        ),
      ),
    );
  }

  // Hàm tạo nút hành động
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            // Kiểm tra form hợp lệ
            if (_formKey.currentState!.validate()) {
              // Kiểm tra ngày đến hạn
              if (_dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng chọn ngày đến hạn')),
                );
                return;
              }
              final now = DateTime.now();
              // Tạo đối tượng Task
              final task = Task(
                id: widget.task?.id ?? now.toString(), // ID mới nếu thêm, giữ nguyên nếu sửa
                title: _titleController.text,
                description: _descriptionController.text,
                status: _status,
                priority: _priority,
                dueDate: _dueDate,
                assignedTo: _assignedTo,
                createdBy: widget.currentUser.id,
                completed: widget.task?.completed ?? false,
                createdAt: widget.task?.createdAt ?? now,
                updatedAt: now,
                category: _categoryController.text.isEmpty ? null : _categoryController.text,
                attachments: _attachments.isEmpty ? null : _attachments,
              );
              try {
                // Thêm hoặc cập nhật công việc
                if (widget.task == null) {
                  await DatabaseHelper.instance.insertTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thêm công việc thành công')),
                  );
                } else {
                  await DatabaseHelper.instance.updateTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cập nhật công việc thành công')),
                  );
                }
                // Quay lại và báo hiệu làm mới
                Navigator.pop(context, true);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi lưu công việc: $error')),
                );
              }
            }
          },
          child: Text(widget.task == null ? 'Thêm' : 'Cập nhật'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context), // Hủy và quay lại
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}