import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onChanged;
  const TaskCard({required this.task, this.onTap, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description ?? ''),
        trailing: Checkbox(value: task.isDone, onChanged: onChanged),
        onTap: onTap,
      ),
    );
  }
}
