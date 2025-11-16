import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../services/firestore_service.dart';

class MoodProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  List<Mood> moods = [];
  StreamSubscription? _sub;

  void start(String userId) {
    _sub?.cancel();
    _sub = _db.streamCollection('moods', userId).listen((list) {
      moods =
          list.map((map) => Mood.fromMap(map['id'] as String, map)).toList();
      moods.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  Future<void> addMood(Mood mood) async {
    await _db.addWithId('moods', mood.id, mood.toMap());
  }

  /// Deleta mood por id
  Future<void> deleteMood(String id) async {
    await _db.delete('moods', id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
