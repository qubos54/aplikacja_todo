import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/widgets/third_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/database/todo_db.dart';
import 'package:flutter_application_1/model/todo.dart';
import 'package:confetti/confetti.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SecondPageState();
  }
}

class SecondPageState extends State<SecondPage> {
  String savedWord = "";
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    // Inicjalizacja stanu
    _loadSavedWord();
    _fetchTodos();
  }

// Metoda do pobierania listy zadań z bazy danych
  void _fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll().then((todos) {
        todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return todos;
      });
    });
  }

// Metoda do wczytywania zapisanego słowa z SharedPreferences
  _loadSavedWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedWord = prefs.getString('savedTextKey') ?? "";
    });
  }

// Metoda do resetowania zapisanego słowa w SharedPreferences
  _resetSavedWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('savedTextKey');
    Navigator.pop(context);
  }

// Metoda do usuwania zadania z bazy danych
  void _deleteTask(int taskId) async {
    await todoDB.delete(taskId);
    List<Todo> updatedTodos = await todoDB.fetchAll();
    updatedTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      futureTodos = Future.value(updatedTodos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Druga strona"),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                Text(
                  "Witaj ",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  savedWord,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 50.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      editMode = !editMode;
                    });
                  },
                  child: Text(editMode ? "Koniec" : "Edycja"),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: editMode,
              child: ElevatedButton(
                child: Text("Edytuj imie"),
                onPressed: _resetSavedWord,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage()),
                ).then((result) {
                  if (result == true) {
                    _fetchTodos();
                  }
                });
              },
              child: Text("Dodaj zadanie"),
            ),
            SizedBox(height: 20),
            Text(
              "Obecne zadania:",
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: FutureBuilder<List<Todo>>(
                future: futureTodos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Todo> todos = snapshot.data!;
                    if (todos.isEmpty) {
                      return Center(
                        child: Text(
                          "Obecnie brak zadań",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TaskListItem(
                              todo: todos[index],
                              onDelete: () {
                                _deleteTask(todos[index].id);
                              },
                              editMode: editMode,
                              todoDB: todoDB,
                            ),
                          );
                        },
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final bool editMode;
  final TodoDB todoDB;

  const TaskListItem({
    required this.todo,
    required this.onDelete,
    required this.editMode,
    required this.todoDB,
    Key? key,
  }) : super(key: key);

  @override
  _TaskListItemState createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      maxBlastForce: 30,
      minBlastForce: 8,
      emissionFrequency: 0.07,
      numberOfParticles: 30,
      gravity: 0.2,
      particleDrag: 0.05,
      colors: const [
        Color.fromARGB(255, 132, 0, 203),
        Colors.blue,
        Colors.lightBlue,
        Color.fromARGB(255, 0, 2, 114),
        Colors.yellow,
      ],
      child: ListTile(
        leading: Checkbox(
          value: widget.todo.isDone,
          onChanged: (value) {
            setState(() {
              widget.todo.isDone = value ?? false;
              widget.todoDB
                  .update(id: widget.todo.id, isDone: widget.todo.isDone);
              if (widget.todo.isDone) {
                _controller.play();
              }
            });
          },
        ),
        title: Text(widget.todo.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Opis: ${widget.todo.description}"),
            Text(
              "Utworzone: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.todo.createdAt)}",
            ),
          ],
        ),
        trailing: widget.editMode
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget.onDelete();
                },
              )
            : null,
      ),
    );
  }
}
