import 'dart:convert';

class Note {
  final int? id;
  final String title;
  final String content;
  final int priority;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags; // Sử dụng List<String> thay vì String?
  final String? color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  // Named constructor for creating a new note
  Note.create({
    required this.title,
    required this.content,
    required this.priority,
    this.tags,
    this.color,
  })  : id = null,
        createdAt = DateTime.now(),
        modifiedAt = DateTime.now();

  // Convert Note to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags != null ? jsonEncode(tags) : null, // Encode tags as JSON string
      'color': color,
    };
  }

  // Create Note from Map retrieved from database
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : null,
      color: map['color'],
    );
  }

  // Create a copy of the current note with updated fields
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(), // Always update modified time
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, createdAt: $createdAt, modifiedAt: $modifiedAt)';
  }
}
