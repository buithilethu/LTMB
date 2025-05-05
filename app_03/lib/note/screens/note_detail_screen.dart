import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/note_database_helper.dart';
import 'note_form_screen.dart';
import '../utils/priority_utils.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;

  const NoteDetailScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteDatabaseHelper _dbHelper = NoteDatabaseHelper();
  Note? _note;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await _dbHelper.getNoteById(widget.noteId);
    setState(() {
      _note = note;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(noteId: widget.noteId),
                ),
              );
              _loadNote(); // Tải lại sau khi chỉnh sửa
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
          ? const Center(child: Text('Không tìm thấy ghi chú'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và mức độ ưu tiên
            Row(
              children: [
                Expanded(
                  child: Text(
                    _note!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                    PriorityUtils.getPriorityColor(_note!.priority),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    PriorityUtils.getPriorityText(_note!.priority),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Thời gian tạo
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Tạo lúc: ${_formatDateTime(_note!.createdAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Thời gian cập nhật
            Row(
              children: [
                const Icon(Icons.update,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Cập nhật: ${_formatDateTime(_note!.modifiedAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nhãn (tags)
            if (_note!.tags != null && _note!.tags!.isNotEmpty) ...[
              const Text(
                'Thẻ:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _note!.tags!
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey.shade200,
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Nội dung
            const Text(
              'Nội dung:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _note!.color != null
                    ? Color(int.parse(
                    _note!.color!.replaceAll('#', '0xFF')))
                    .withOpacity(0.1)
                    : PriorityUtils.getPriorityColor(_note!.priority)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _note!.color != null
                      ? Color(int.parse(_note!.color!
                      .replaceAll('#', '0xFF')))
                      .withOpacity(0.3)
                      : PriorityUtils.getPriorityColor(
                      _note!.priority)
                      .withOpacity(0.3),
                ),
              ),
              child: Text(
                _note!.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
