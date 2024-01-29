import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/database/database_service.dart';
import 'package:flutter_application_1/model/todo.dart';

class TodoDB {
  final tableName = 'todos';

// Metoda tworząca tabelę w bazie danych, jeśli nie istnieje
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as INTEGER)),
    "updated_at" INTEGER,
    "is_done" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("id" AUTOINCREMENT)
  );""");
  }

// Metoda dodająca nowe zadanie do bazy danych
  Future<int> create({
    required String title,
    required String description,
    bool isDone = false,
  }) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (title, description, created_at) VALUES (?, ?, ?)''',
      [
        title,
        description,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

// Metoda pobierająca wszystkie zadania z bazy danych
  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
        '''SELECT * from $tableName ORDER BY COALESCE(updated_at,created_at)''');
    return todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();
  }

// Metoda pobierająca zadanie z bazy danych na podstawie jego id
  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

// Metoda aktualizująca zadanie w bazie danych
  Future<int> update({
    required int id,
    String? title,
    String? description,
    bool? isDone,
  }) async {
    final database = await DatabaseService().database;
    final Map<String, dynamic> dataToUpdate = {};

    if (title != null) dataToUpdate['title'] = title;
    if (description != null) dataToUpdate['description'] = description;
    if (isDone != null) dataToUpdate['is_done'] = isDone ? 1 : 0;
    dataToUpdate['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      tableName,
      dataToUpdate,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Metoda usuwająca zadanie z bazy danych na podstawie jego id
  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ?''', [id]);
  }

  Future<bool> taskExists(int taskId) async {
    final database = await DatabaseService().database;
    final result = await database.rawQuery('SELECT COUNT(*) FROM todos WHERE id = ?', [taskId]);
    final count = Sqflite.firstIntValue(result)!;
    return count > 0;
  }
}
