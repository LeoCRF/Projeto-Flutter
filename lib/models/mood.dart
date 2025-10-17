class Mood {
  String id;
  String userId;
  int moodLevel;
  String? note;
  DateTime date;

  Mood({
    required this.id,
    required this.userId,
    required this.moodLevel,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'moodLevel': moodLevel,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Mood.fromMap(String id, Map<String, dynamic> map) => Mood(
        id: id,
        userId: map['userId'] ?? '',
        moodLevel: map['moodLevel'] ?? 2,
        note: map['note'],
        date: DateTime.parse(map['date']),
      );
}
