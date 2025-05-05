import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndNote();
  }

  Future<void> _loadUserIdAndNote() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      _isLoading = true;
    });
    if (_userId != null) {
      await _loadNote();
    }
  }

  Future<void> _loadNote() async {
    if (_userId == null) return;
    final note = await _dbHelper.getNoteById(widget.noteId, _userId!);
    setState(() {
      _note = note;
      _isLoading = false;
    });
  }

  void _deleteNote() async {
    if (_note != null && _userId != null) {
      await _dbHelper.deleteNote(_note!.id!, _userId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ghi chú')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc muốn xóa ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
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
              _loadNote();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: _isLoading || _userId == null
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Không tìm thấy ghi chú'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: PriorityUtils.getPriorityColor(
                                  _note!.priority),
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
                                ? Color(int.parse(
                                        _note!.color!.replaceAll('#', '0xFF')))
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

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
