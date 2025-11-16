import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mood.dart';
import 'package:uuid/uuid.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  int selected = 1;
  final controller = TextEditingController();
  bool _saving = false;

  String getMoodText(int level) {
    switch (level) {
      case 3:
        return "Feliz";
      case 2:
        return "Ok";
      case 1:
        return "Neutro";
      default:
        return "Triste";
    }
  }

  String getEmoji(int level) {
    switch (level) {
      case 3:
        return "😄";
      case 2:
        return "🙂";
      case 1:
        return "😐";
      default:
        return "😞";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    if (auth.user == null) {
      return const Center(child: Text('Faça login para registrar humor'));
    }

    moodProvider.start(auth.user!.uid);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Como você está hoje?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moodIcon(0, '😞'),
              _moodIcon(1, '😐'),
              _moodIcon(2, '🙂'),
              _moodIcon(3, '😄'),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Anote algo (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      final mood = Mood(
                        id: const Uuid().v4(),
                        userId: auth.user!.uid,
                        moodLevel: selected,
                        note: controller.text,
                        date: DateTime.now(),
                      );
                      await moodProvider.addMood(mood);

                      controller.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Humor registrado')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<MoodProvider>(
              builder: (context, prov, _) {
                final list = prov.moods;

                final reversed = list.reversed.toList();

                if (list.isEmpty) {
                  return const Center(child: Text('Nenhum registro'));
                }

                return ListView.builder(
                  itemCount: reversed.length,
                  itemBuilder: (context, i) {
                    final m = reversed[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Text(
                          getEmoji(m.moodLevel),
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          getMoodText(m.moodLevel),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.note != null && m.note!.trim().isNotEmpty)
                              Text(m.note!),
                            Text(
                              '${m.date.day}/${m.date.month}/${m.date.year}   '
                              '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir registro'),
                                content: const Text(
                                    'Tem certeza que deseja apagar este humor?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Excluir')),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              moodProvider.deleteMood(m.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodIcon(int value, String emoji) {
    final selectedVal = selected == value;
    return GestureDetector(
      onTap: () => setState(() => selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedVal ? Colors.blue.shade100 : Colors.grey.shade200,
          border: Border.all(
              color: selectedVal ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
