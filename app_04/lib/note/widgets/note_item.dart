import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/priority_utils.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteItem({
    Key? key,
    required this.note,
    this.isListView = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color != null
          ? Color(int.parse(note.color!.replaceAll('#', '0xFF')))
          : PriorityUtils.getPriorityColor(note.priority),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                maxLines: isListView ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: note.tags!
                      .map((tag) => Chip(
                            label:
                                Text(tag, style: const TextStyle(fontSize: 12)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ))
                      .toList(),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
