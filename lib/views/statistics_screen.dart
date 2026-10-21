import 'package:flutter/material.dart';

import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final active = total - completed;

    final Map<String, int> categoryCounts = {};
    for (var task in tasks) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Загалом задач'),
                trailing: Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Виконано'),
                trailing: Text(
                  '$completed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Активні'),
                trailing: Text(
                  '$active',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'По категоріях:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...categoryCounts.entries.map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
