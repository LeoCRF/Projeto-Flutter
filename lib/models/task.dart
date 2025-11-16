import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime date;
  final String userId;
  final String? mood;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.date,
    required this.userId,
    this.mood,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'isDone': isDone,
        'date': date.toIso8601String(),
        'userId': userId,
        'mood': mood,
      };

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;

    if (rawDate == null) {
      parsedDate = DateTime.now();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      isDone: map['isDone'] ?? false,
      date: parsedDate,
      userId: map['userId'] ?? '',
      mood: map['mood'],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? date,
    String? userId,
    String? mood, // <-- COPIAR HUMOR
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood, // <-- MANTÉM OU ATUALIZA
    );
  }
}
