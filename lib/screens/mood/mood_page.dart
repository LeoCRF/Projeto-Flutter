import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  int selected = 2;
  final controller = TextEditingController();
  final FirestoreService _db = FirestoreService();
  bool isSaving = false;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Como você está hoje?', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Data: '),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime.now(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(Icons.sentiment_very_dissatisfied),
                  color: selected == 1 ? Colors.red : null,
                  onPressed: () => setState(() => selected = 1)),
              IconButton(
                  icon: const Icon(Icons.sentiment_neutral),
                  color: selected == 2 ? Colors.orange : null,
                  onPressed: () => setState(() => selected = 2)),
              IconButton(
                  icon: const Icon(Icons.sentiment_very_satisfied),
                  color: selected == 3 ? Colors.green : null,
                  onPressed: () => setState(() => selected = 3)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration:
                const InputDecoration(labelText: 'Anote algo (opcional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: auth.user == null || isSaving
                ? null
                : () async {
                    setState(() => isSaving = true);
                    // Evita registro duplicado no mesmo dia
                    final now = selectedDate;
                    final today = DateTime(now.year, now.month, now.day);
                    // Busca apenas o primeiro registro do dia para evitar lentidão
                    final query = await _db.db
                        .collection('moods')
                        .where('userId', isEqualTo: auth.user!.uid)
                        .where('date',
                            isGreaterThanOrEqualTo: today.toIso8601String())
                        .where('date',
                            isLessThan:
                                DateTime(now.year, now.month, now.day + 1)
                                    .toIso8601String())
                        .limit(1)
                        .get();
                    if (query.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Você já registrou seu humor hoje.')),
                      );
                      setState(() => isSaving = false);
                      return;
                    }
                    final mood = Mood(
                      id: '',
                      userId: auth.user!.uid,
                      moodLevel: selected,
                      note: controller.text,
                      date: selectedDate,
                    );
                    await _db.add('moods', mood.toMap());
                    controller.clear();
                    setState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Humor registrado!')));
                  },
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Salvar'),
          ),
          const SizedBox(height: 24),
          const Text('Histórico de humor', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          if (auth.user != null)
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _db.streamCollection('moods', auth.user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(
                        child: Text('Nenhum registro de humor'));
                  }
                  final moods = items
                      .map((m) => Mood.fromMap(m['id'], m))
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
                  // Gráfico: últimos 14 dias (preenche dias sem registro)
                  final now = DateTime.now();
                  final days = List.generate(14, (i) {
                    final d = DateTime(now.year, now.month, now.day - 13 + i);
                    return d;
                  });
                  final moodMap = {
                    for (var m in moods)
                      '${m.date.year}-${m.date.month}-${m.date.day}': m
                  };
                  final spots = <FlSpot>[];
                  for (int i = 0; i < days.length; i++) {
                    final key =
                        '${days[i].year}-${days[i].month}-${days[i].day}';
                    final mood = moodMap[key];
                    spots.add(FlSpot(
                        i.toDouble(), (mood?.moodLevel ?? 2).toDouble()));
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (v, _) {
                                      switch (v.toInt()) {
                                        case 1:
                                          return const Text('Ruim');
                                        case 2:
                                          return const Text('Neutro');
                                        case 3:
                                          return const Text('Bom');
                                        default:
                                          return Text(v.toString());
                                      }
                                    }),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, meta) {
                                      if (v.toInt() < days.length) {
                                        final d = days[v.toInt()];
                                        return Text('${d.day}/${d.month}');
                                      }
                                      return const Text('');
                                    }),
                              ),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            minY: 1,
                            maxY: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: moods.length,
                          itemBuilder: (context, i) {
                            final m = moods[
                                moods.length - 1 - i]; // mais recente primeiro
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 0),
                              child: ListTile(
                                leading: Icon(
                                  m.moodLevel == 1
                                      ? Icons.sentiment_very_dissatisfied
                                      : m.moodLevel == 2
                                          ? Icons.sentiment_neutral
                                          : Icons.sentiment_very_satisfied,
                                  color: m.moodLevel == 1
                                      ? Colors.red
                                      : m.moodLevel == 2
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                                title: Text(m.note?.isNotEmpty == true
                                    ? m.note!
                                    : '(sem observação)'),
                                subtitle: Text(
                                    '${m.date.day}/${m.date.month} ${m.date.hour}:${m.date.minute.toString().padLeft(2, '0')}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
