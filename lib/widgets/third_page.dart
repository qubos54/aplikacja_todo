import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/todo_db.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ThirdPageState();
  }
}

class ThirdPageState extends State<ThirdPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

// Metoda dodająca zadanie do bazy danych
  void _addTaskToDatabase() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty) {
      TodoDB todoDB = TodoDB();
      await todoDB.create(title: title, description: description);

      _titleController.clear();
      _descriptionController.clear();

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trzecia strona"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tytul zadania',
                  contentPadding: EdgeInsets.all(10.0),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Opis zadania',
                  contentPadding: EdgeInsets.all(10.0),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Dodaj zadanie"),
                onPressed: _addTaskToDatabase,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
