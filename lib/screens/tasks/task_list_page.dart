import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  static const int pageSize = 20;
  int _currentMax = pageSize;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (auth.user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return StreamBuilder<List<Task>>(
      stream: taskProvider.streamTasks(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Center(child: Text('Nenhuma tarefa encontrada'));
        }

        tasks.sort((a, b) => b.date.compareTo(a.date));
        final limited = tasks.take(_currentMax).toList();

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                _currentMax < tasks.length) {
              setState(() => _currentMax += pageSize);
            }
            return false;
          },
          child: ListView.builder(
            itemCount: limited.length,
            itemBuilder: (context, i) {
              final task = limited[i];

              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir tarefa?'),
                      content: const Text(
                          'Tem certeza que deseja excluir esta tarefa?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Excluir')),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await taskProvider.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tarefa excluída')));
                },
                child: Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  color: task.isDone ? Colors.green[50] : null,
                  child: ListTile(
                    leading: Icon(
                      task.isDone
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.isDone ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.green : null,
                      ),
                    ),
                    subtitle: task.description?.isNotEmpty == true
                        ? Text(task.description!)
                        : null,
                    trailing: Checkbox(
                      value: task.isDone,
                      onChanged: (v) async {
                        final updated = task.copyWith(isDone: v ?? false);
                        await taskProvider.updateTask(updated);
                      },
                    ),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/task_form',
                        arguments: task,
                      );

                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
