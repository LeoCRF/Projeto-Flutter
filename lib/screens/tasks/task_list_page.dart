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
  List<Task>? _cachedTasks;
  // bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (auth.user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: taskProvider.streamTasks(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedTasks == null) {
          // Shimmer loading
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (context, i) => const ListTile(
              title: SizedBox(
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
              subtitle: SizedBox(
                height: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
            ),
          );
        }
        final items = snapshot.data ??
            _cachedTasks?.map((t) => t.toMap()..['id'] = t.id).toList() ??
            [];
        if (snapshot.hasData) {
          _cachedTasks =
              items.map((map) => Task.fromMap(map['id'], map)).toList();
          // _isLoading = false;
        }
        if (items.isEmpty) {
          return const Center(child: Text('Nenhuma tarefa encontrada'));
        }
        // Ordena por data (descendente)
        items.sort((a, b) => b['date'].compareTo(a['date']));
        final limited = items.take(_currentMax).toList();
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                _currentMax < items.length) {
              setState(() {
                _currentMax += pageSize;
              });
            }
            return false;
          },
          child: ListView.builder(
            itemCount: limited.length,
            itemBuilder: (context, i) {
              final map = limited[i];
              final task = Task.fromMap(map['id'], map);
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
                        setState(() {
                          task.isDone = v ?? false;
                        });
                        await taskProvider.updateTask(task);
                      },
                    ),
                    onTap: () => Navigator.pushNamed(context, '/task_form',
                        arguments: task),
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
