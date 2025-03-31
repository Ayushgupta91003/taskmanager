import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({Key? key}) : super(key: key);

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? dueDate;

  // Function to pick a due date
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

  // Function to create a new task
  Future<void> createTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse("http://10.0.3.236:5000/api/tasks");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "dueDate": dueDate?.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: "Task created successfully");
      Navigator.pop(
          context, true); // Return to previous screen with a success flag.
    } else {
      Fluttertoast.showToast(msg: "Failed to create task: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
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
                onPressed: createTask,
                child: Text("Create Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
