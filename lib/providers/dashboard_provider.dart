import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/mood.dart';

class DashboardProvider extends ChangeNotifier {
  List<Task> tasks = [];
  List<Mood> moods = [];

  void updateTasks(List<Task> t) {
    tasks = t;
    notifyListeners();
  }

  void updateMoods(List<Mood> m) {
    moods = m;
    notifyListeners();
  }

  int get totalTasks => tasks.length;
  int get doneTasks => tasks.where((t) => t.isDone).length;
  double get avgMood => moods.isNotEmpty
      ? moods.map((m) => m.moodLevel).reduce((a, b) => a + b) / moods.length
      : 0.0;
}
