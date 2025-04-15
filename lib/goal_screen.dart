import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Goal {
  final String title;
  final String description;
  final String category;
  final DateTime targetDate;
  final double progress;

  Goal({
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'targetDate': targetDate.toIso8601String(),
    'progress': progress,
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      targetDate: DateTime.parse(json['targetDate']),
      progress: json['progress'],
    );
  }
}

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('goals');
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      setState(() {
        _goals = decodedList.map((item) => Goal.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_goals.map((goal) => goal.toJson()).toList());
    await prefs.setString('goals', jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(goal.description),
                  const SizedBox(height: 5),
                  Text('Category: ${goal.category}'),
                  const SizedBox(height: 5),
                  Text('Target Date: ${goal.targetDate}'),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(value: goal.progress),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _goals.add(
              Goal(
                title: 'New Goal',
                description: 'Description',
                category: 'Category',
                targetDate: DateTime.now().add(const Duration(days: 30)),
                progress: 0.0,
              ),
            );
            _saveGoals();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
