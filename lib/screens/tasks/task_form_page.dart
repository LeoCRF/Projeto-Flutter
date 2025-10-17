import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  bool isEdit = false;
  Task? editing;
  DateTime selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Task) {
      editing = args;
      isEdit = true;
      title = editing!.title;
      description = editing!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Tarefa' : 'Nova Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (v) => title = v,
                validator: (v) => v!.isEmpty ? 'Informe um título' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Data: '),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(DateTime.now().year - 2),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && auth.user != null) {
                    final navigator = Navigator.of(context);
                    if (isEdit && editing != null) {
                      editing!.title = title;
                      editing!.description = description;
                      editing!.date = selectedDate;
                      await taskProvider.updateTask(editing!);
                    } else {
                      final t = Task(
                        id: const Uuid().v4(),
                        title: title,
                        description: description,
                        date: selectedDate,
                        userId: auth.user!.uid,
                      );
                      await taskProvider.addTask(t);
                    }
                    if (!mounted) return;
                    navigator.pop();
                  }
                },
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
