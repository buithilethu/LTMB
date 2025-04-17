import 'package:flutter/material.dart';
import '../model/note.dart';
import '../view/noteformscreen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết '),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ưu tiên: ${note.priority}',
                  style: TextStyle(color: _getPriorityColor()),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Tạo: ${_formatDate(note.createdAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Lần sửa cuối: ${_formatDate(note.modifiedAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (note.priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}