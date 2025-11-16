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
  bool _isSaving = false;

  final List<String> moods = ['😄', '🙂', '😐', '😔', '😢', '😡'];
  String? selectedMood;

  bool _loadedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Task) {
      editing = args;
      isEdit = true;
      title = editing!.title;
      description = editing!.description ?? '';
      selectedDate = editing!.date;
      selectedMood = editing!.mood;
    }
    _loadedArgs = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Tarefa' : 'Nova Tarefa'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
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
                if (confirm == true && editing != null) {
                  try {
                    await taskProvider.deleteTask(editing!.id);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao excluir: $e')));
                  }
                }
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (v) => title = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe um título' : null,
              ),
              const SizedBox(height: 8),
              // DESCRIÇÃO
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (v) => description = v,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              const Text(
                "Humor (opcional):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: moods.map((m) {
                  final isSelected = selectedMood == m;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (auth.user == null) return;
                            setState(() => _isSaving = true);

                            try {
                              if (isEdit && editing != null) {
                                final updated = editing!.copyWith(
                                  title: title,
                                  description: description,
                                  date: selectedDate,
                                  mood: selectedMood,
                                );
                                await taskProvider.updateTask(updated);
                              } else {
                                final id = const Uuid().v4();
                                final newTask = Task(
                                  id: id,
                                  title: title,
                                  description: description,
                                  date: selectedDate,
                                  userId: auth.user!.uid,
                                  mood: selectedMood,
                                );
                                await taskProvider.addTask(newTask);
                              }

                              if (!mounted) return;
                              Navigator.of(context).pop();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro: $e')));
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
