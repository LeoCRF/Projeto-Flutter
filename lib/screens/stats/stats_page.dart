import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/mood_provider.dart';
import '../../providers/auth_provider.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final moodProv = Provider.of<MoodProvider>(context);

    if (auth.user == null) return const Center(child: Text('Faça login'));

    moodProv.start(auth.user!.uid);

    final moods = moodProv.moods;
    if (moods.isEmpty) return const Center(child: Text('Sem dados de humor'));

    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 6));
    final recent = moods.where((m) => m.date.isAfter(lastWeek)).toList();

    final moodMap = {0: '😞', 1: '😐', 2: '🙂', 3: '😄'};

    final counts = {for (var key in moodMap.keys) key: 0};
    for (var m in recent) {
      if (counts.containsKey(m.moodLevel))
        counts[m.moodLevel] = counts[m.moodLevel]! + 1;
    }

    final maxCount = counts.values.isEmpty
        ? 1
        : (counts.values.reduce((a, b) => a > b ? a : b));

    final barGroups = moodMap.entries.map((entry) {
      final level = entry.key;
      final value = counts[level]!.toDouble();
      return BarChartGroupData(
        x: level,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 40,
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary,
            rodStackItems: [],
          ),
        ],
        showingTooltipIndicators: value > 0 ? [0] : [],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Humor nos últimos 7 dias',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (val, meta) {
                        final level = val.toInt();
                        if (!moodMap.containsKey(level))
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            moodMap[level]!,
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          val.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final level = group.x.toInt();
                      final count = rod.toY.toInt();
                      return BarTooltipItem(
                        '${moodMap[level]}: $count',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  )
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
