import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import 'create_task_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskStorageService _storageService = TaskStorageService();
  List<Task> _allTasks = [];
  bool _isLoading = true;

  String _selectedCategory = 'Усі';
  bool? _statusFilter;
  String _sortBy = 'date_desc';

  final List<String> _categories = [
    'Усі',
    'Робота',
    'Навчання',
    'Особисте',
    'Дім',
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.getTasks();
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_allTasks);
  }

  void _toggleTaskStatus(Task task) {
    setState(() {
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final newStatus = !_allTasks[index].isCompleted;
        _allTasks[index] = _allTasks[index].copyWith(
          isCompleted: newStatus,
          completedAt: newStatus ? DateTime.now() : null,
        );
      }
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    final taskIndex = _allTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return;

    final deletedTask = _allTasks[taskIndex];

    setState(() {
      _allTasks.removeAt(taskIndex);
    });
    _saveTasks();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задачу "${deletedTask.title}" видалено'),
        action: SnackBarAction(
          label: 'Скасувати',
          onPressed: () {
            setState(() {
              _allTasks.insert(taskIndex, deletedTask);
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _clearCompletedTasks() {
    final completedCount = _allTasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити всі виконані?'),
        content: Text('Буде видалено $completedCount задач(і).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allTasks.removeWhere((t) => t.isCompleted);
              });
              _saveTasks();
              Navigator.pop(ctx);
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  List<Task> get _filteredTasks {
    var list = List<Task>.from(_allTasks);

    if (_selectedCategory != 'Усі') {
      list = list.where((t) => t.category == _selectedCategory).toList();
    }

    if (_statusFilter != null) {
      list = list.where((t) => t.isCompleted == _statusFilter).toList();
    }

    list.sort((a, b) {
      if (_sortBy == 'date_desc') {
        return b.createdAt.compareTo(a.createdAt);
      } else if (_sortBy == 'date_asc') {
        return a.createdAt.compareTo(b.createdAt);
      } else if (_sortBy == 'priority') {
        return b.priority.compareTo(a.priority);
      }
      return 0;
    });

    return list;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksToDisplay = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Статистика',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(tasks: _allTasks),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Видалити виконані',
            onPressed: _clearCompletedTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ..._categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      DropdownButton<bool?>(
                        value: _statusFilter,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Усі статуси'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Активні'),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Виконані'),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _statusFilter = val;
                          });
                        },
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'date_desc',
                            child: Text('Спочатку нові'),
                          ),
                          DropdownMenuItem(
                            value: 'date_asc',
                            child: Text('Спочатку старі'),
                          ),
                          DropdownMenuItem(
                            value: 'priority',
                            child: Text('За пріоритетом'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _sortBy = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: tasksToDisplay.isEmpty
                      ? const Center(child: Text('Задач не знайдено'))
                      : ListView.builder(
                          itemCount: tasksToDisplay.length,
                          itemBuilder: (context, index) {
                            final task = tasksToDisplay[index];
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                _deleteTask(task);
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => _toggleTaskStatus(task),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (task.description.isNotEmpty)
                                        Text(task.description),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          Chip(
                                            label: Text(
                                              task.category,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                          ),
                                          ...task.tags.map(
                                            (tag) => Chip(
                                              label: Text(
                                                '#$tag',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: _getPriorityColor(
                                      task.priority,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );

          if (newTask != null) {
            setState(() {
              _allTasks.add(newTask);
            });
            _saveTasks();
          }
        },
      ),
    );
  }
}
