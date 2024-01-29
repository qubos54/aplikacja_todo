import 'package:path/path.dart';
import 'package:flutter_application_1/database/todo_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  Database? _database;

// Metoda zwracająca obiekt bazy danych
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

// Metoda zwracająca pełną ścieżkę do bazy danych
  Future<String> get fullPath async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    const name = 'todo.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

// Metoda inicjalizująca bazę danych
  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await TodoDB().createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {}
      },
    );
    return database;
  }
}
