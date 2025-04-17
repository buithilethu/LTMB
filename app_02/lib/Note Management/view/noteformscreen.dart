import 'package:flutter/material.dart';
import '../database/databasehelper.dart';
import '../model/note.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String content;
  late int priority;
  late List<String> tags;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    priority = widget.note?.priority ?? 1;
    tags = widget.note?.tags != null ? List.from(widget.note!.tags!) : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Ghi chú mới' : 'Sửa ghi chứ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Hãy nhập tiêu đề ' : null,
                  onSaved: (value) => title = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: content,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                  value!.isEmpty ? 'Hãy nhập nội dung' : null,
                  onSaved: (value) => content = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Mức độ ưu tiên',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Thấp')),
                    DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) => setState(() => priority = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    labelText: 'Thêm nhãn',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_tagController.text.isNotEmpty) {
                          setState(() {
                            tags.add(_tagController.text);
                            _tagController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => tags.remove(tag)),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(widget.note == null ? 'Tạo' : 'Cập nhật'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final newNote = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        priority: priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: tags.isNotEmpty ? tags : null,
      );

      try {
        if (widget.note == null) {
          await NoteDatabaseHelper.instance.insertNote(newNote);
        } else {
          await NoteDatabaseHelper.instance.updateNote(newNote);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')),
        );
      }
    }
  }
}