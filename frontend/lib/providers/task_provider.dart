// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskProvider with ChangeNotifier {
  List _tasks = [];
  bool _isLoading = false;

  List get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Fetch tasks from backend API
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse("http://10.0.3.236:5000/api/tasks");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tasks = data['tasks'];
      } else {
        Fluttertoast.showToast(msg: "Failed to load tasks");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: $error");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Add a new task locally
  void addTask(Map newTask) {
    _tasks.add(newTask);
    notifyListeners();
  }

  // Remove a task locally by its id
  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task['_id'] == taskId);
    notifyListeners();
  }

  // Update a task locally with new data
  void updateTask(Map updatedTask) {
    int index = _tasks.indexWhere((task) => task['_id'] == updatedTask['_id']);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }
}
