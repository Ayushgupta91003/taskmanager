import 'package:flutter/material.dart';
import 'package:frontend/screens/task_creation_screen.dart';
import 'package:frontend/screens/task_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];
  bool isLoading = true;

  Future<void> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse("http://10.0.3.236:5000/api/tasks");
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        tasks = data['tasks'];
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Failed to load tasks");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Tasks"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Clear token and navigate to login
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['title']),
                  subtitle: Text(task['description'] ?? ""),
                  trailing: Text(task['status']),
                  // onTap: () {
                  //   // Yahan aap update/delete ka logic daal sakte hain ya task detail screen par navigate kar sakte hain.
                  // },
                  // Inside ListTile onTap in TaskListScreen
                  onTap: () async {
                    bool? refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
                      ),
                    );
                    if (refresh == true) {
                      fetchTasks(); // Refresh task list on return
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        // Example in TaskListScreen:
        onPressed: () async {
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskCreationScreen()),
          );
          if (refresh == true) {
            fetchTasks(); // Function to refresh task list
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
