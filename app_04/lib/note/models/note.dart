class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final int priority;
  final String createdAt;
  final String modifiedAt;
  final List<String>? tags;
  final String? color;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'tags': tags?.join(','),
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: map['createdAt'],
      modifiedAt: map['modifiedAt'],
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
      color: map['color'],
    );
  }

  Note copyWith({
    String? title,
    String? content,
    int? priority,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      modifiedAt: DateTime.now().toIso8601String(),
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  static Note create({
    required int userId,
    required String title,
    required String content,
    required int priority,
    List<String>? tags,
    String? color,
  }) {
    final now = DateTime.now().toIso8601String();
    return Note(
      userId: userId,
      title: title,
      content: content,
      priority: priority,
      createdAt: now,
      modifiedAt: now,
      tags: tags,
      color: color,
    );
  }
}
