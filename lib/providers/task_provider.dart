import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  List<Task> tasks = [];

  Stream<List<Map<String, dynamic>>> streamTasks(String userId) =>
      _db.streamCollection('tasks', userId);

  Future<void> addTask(Task task) async {
    await _db.add('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _db.update('tasks', task.id, task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.delete('tasks', taskId);
  }
}
