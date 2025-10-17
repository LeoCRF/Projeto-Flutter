import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../models/mood.dart';
import '../../services/firestore_service.dart';
import '../../services/theme_service.dart';
import '../tasks/task_list_page.dart';
import '../mood/mood_page.dart';
import '../stats/stats_page.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int)? onShortcutTap;
  const DashboardPage({Key? key, this.onShortcutTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.user?.uid;
    if (userId == null) {
      return const Center(child: Text('Faça login para ver o dashboard'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bem-vindo!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Aqui está um resumo do seu dia:',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Provider.of<TaskProvider>(context, listen: false)
                    .streamTasks(userId),
                builder: (context, snapshot) {
                  final tasks = (snapshot.data ?? [])
                      .map((t) => Task.fromMap(t['id'], t))
                      .toList();
                  final total = tasks.length;
                  final done = tasks.where((t) => t.isDone).length;
                  final pending = total - done;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DashStat(
                          label: 'Tarefas',
                          value: total.toString(),
                          color: Colors.blue),
                      DashStat(
                          label: 'Concluídas',
                          value: done.toString(),
                          color: Colors.green),
                      DashStat(
                          label: 'Pendentes',
                          value: pending.toString(),
                          color: Colors.orange),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirestoreService().streamCollection('moods', userId),
                builder: (context, snapshot) {
                  final moods = (snapshot.data ?? [])
                      .map((m) => Mood.fromMap(m['id'], m))
                      .toList();
                  final avg = moods.isNotEmpty
                      ? moods.map((m) => m.moodLevel).reduce((a, b) => a + b) /
                          moods.length
                      : 0.0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DashStat(
                          label: 'Humor Médio',
                          value: avg.toStringAsFixed(2),
                          color: Colors.purple),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DashShortcut(
                  icon: Icons.task,
                  label: 'Tarefas',
                  route: 1,
                  onTap: onShortcutTap),
              DashShortcut(
                  icon: Icons.mood,
                  label: 'Humor',
                  route: 2,
                  onTap: onShortcutTap),
              DashShortcut(
                  icon: Icons.bar_chart,
                  label: 'Estatísticas',
                  route: 3,
                  onTap: onShortcutTap),
            ],
          ),
        ],
      ),
    );
  }
}

class DashStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const DashStat(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 16, color: color)),
      ],
    );
  }
}

class DashShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final int route;
  final void Function(int)? onTap;
  const DashShortcut(
      {required this.icon,
      required this.label,
      required this.route,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(route),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onShortcutTap: (i) => setState(() => _index = i)),
      const TaskListPage(),
      const MoodPage(),
      const StatsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus.Me'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final themeService =
                  Provider.of<ThemeService>(context, listen: false);
              themeService.toggle();
            },
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
            },
          )
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tarefas'),
          NavigationDestination(icon: Icon(Icons.mood), label: 'Humor'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
        ],
      ),
      floatingActionButton: _index == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/task_form'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
