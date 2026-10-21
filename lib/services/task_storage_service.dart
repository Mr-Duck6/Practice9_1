import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _storageKey = 'todo_tasks_list';

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_storageKey);
    if (tasksString == null) return [];

    final List<dynamic> decodedList = jsonDecode(tasksString);
    return decodedList.map((item) => Task.fromJson(item)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encodedList);
  }
}