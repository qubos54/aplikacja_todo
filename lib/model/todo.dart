class Todo {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  bool isDone;

// Konstruktor klasy Todo
  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.isDone = false,
  });

  // Fabryczna metoda tworząca obiekt Todo na podstawie mapy danych z bazy SQLite
  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
        id: map['id']?.toInt() ?? 0, // Pobierz id zadania lub ustaw domyślnie na 0
        title: map['title'] ?? '', // Pobierz tytuł zadania lub ustaw domyślnie na pusty ciąg znaków
        description: map['description'] ?? '', // Pobierz opis zadania lub ustaw domyślnie na pusty ciąg znaków
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']), // Pobierz datę utworzenia zadania
        updatedAt: map['updated_at'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['updated_at']), // Jeśli brak daty aktualizacji, ustaw na null, przeciwnym razie pobierz datę aktualizacji zadania
        isDone: map['is_done'] == 1, // Pobierz informację o zakończeniu zadania (1 oznacza true)
      );
}
