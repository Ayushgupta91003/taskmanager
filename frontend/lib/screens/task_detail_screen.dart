import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map task; // Pass task details as a Map

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String status = "pending";
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task details
    _titleController.text = widget.task['title'] ?? "";
    _descriptionController.text = widget.task['description'] ?? "";
    status = widget.task['status'] ?? "pending";
    if (widget.task['dueDate'] != null) {
      dueDate = DateTime.parse(widget.task['dueDate']);
    }
  }

  // Function to update task via PUT request
  Future<void> updateTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse("http://10.0.3.236:5000/api/tasks/${widget.task['_id']}");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "status": status,
        "dueDate": dueDate?.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Task updated successfully");
      Navigator.pop(context, true); // Pass true to indicate refresh needed.
    } else {
      Fluttertoast.showToast(msg: "Update failed: ${response.body}");
    }
  }

  // Function to delete task via DELETE request
  Future<void> deleteTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse("http://10.0.3.236:5000/api/tasks/${widget.task['_id']}");
    final response = await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Task deleted successfully");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Delete failed: ${response.body}");
    }
  }

  // Function to pick a due date using date picker
  Future<void> pickDueDate() async {
    DateTime initialDate = dueDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Detail"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Confirm deletion
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete Task"),
                  content: Text("Are you sure you want to delete this task?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteTask();
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10),
            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 10),
            // Dropdown for Status
            DropdownButton<String>(
              value: status,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    status = newValue;
                  });
                }
              },
              items: <String>['pending', 'completed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Due Date Selector
            Row(
              children: [
                Expanded(
                  child: Text(
                    dueDate != null
                        ? "Due Date: ${dueDate!.toLocal().toString().split(' ')[0]}"
                        : "Select Due Date",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: pickDueDate,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateTask,
              child: Text("Update Task"),
            )
          ],
        ),
      ),
    );
  }
}
