class Task {
  String id;
  String title;
  String? description;
  bool isDone;
  DateTime date;
  String userId;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'isDone': isDone,
        'date': date.toIso8601String(),
        'userId': userId,
      };

  factory Task.fromMap(String id, Map<String, dynamic> map) => Task(
        id: id,
        title: map['title'] ?? '',
        description: map['description'],
        isDone: map['isDone'] ?? false,
        date: DateTime.parse(map['date']),
        userId: map['userId'],
      );
}
