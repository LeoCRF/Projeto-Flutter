import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
// import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../services/firestore_service.dart';
import '../../models/mood.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.user?.uid;
    if (userId == null) {
      return const Center(child: Text('Faça login para ver estatísticas'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().streamCollection('tasks', userId),
              builder: (context, taskSnapshot) {
                if (taskSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = (taskSnapshot.data ?? [])
                    .map((t) => Task.fromMap(t['id'], t))
                    .toList();
                final totalTasks = tasks.length;
                final completedTasks = tasks.where((t) => t.isDone).length;
                final pendingTasks = totalTasks - completedTasks;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(
                          label: 'Total',
                          value: totalTasks.toString(),
                          color: Colors.blue,
                        ),
                        _StatCard(
                          label: 'Concluídas',
                          value: completedTasks.toString(),
                          color: Colors.green,
                        ),
                        _StatCard(
                          label: 'Pendentes',
                          value: pendingTasks.toString(),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream:
                          FirestoreService().streamCollection('moods', userId),
                      builder: (context, moodSnapshot) {
                        if (moodSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final moods = (moodSnapshot.data ?? [])
                            .map((m) => Mood.fromMap(m['id'], m))
                            .toList();
                        final moodAvg = moods.isNotEmpty
                            ? (moods
                                    .map((m) => m.moodLevel)
                                    .reduce((a, b) => a + b) /
                                moods.length)
                            : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _StatCard(
                                  label: 'Humor Médio',
                                  value: moodAvg.toStringAsFixed(2),
                                  color: Colors.purple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            moods.length >= 2
                                ? SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: true),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: true),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: moods
                                                .asMap()
                                                .entries
                                                .map((e) => FlSpot(
                                                    e.key.toDouble(),
                                                    e.value.moodLevel
                                                        .toDouble()))
                                                .toList(),
                                            isCurved: true,
                                            color: Colors.purple,
                                            barWidth: 4,
                                            dotData: FlDotData(show: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Adicione mais registros de humor para ver o gráfico.'),
                          ],
                        );
                      },
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
