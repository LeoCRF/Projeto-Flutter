import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  Stream<List<Task>> streamTasks(String userId) {
    return _db.streamCollection('tasks', userId).map(
          (list) => list
              .map((map) => Task.fromMap(map['id'] as String, map))
              .toList(),
        );
  }

  Future<void> addTask(Task task) async {
    await _db.addWithId('tasks', task.id, task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _db.update('tasks', task.id, task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.delete('tasks', taskId);
  }
}
