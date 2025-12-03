class Record {
  int? id; // auto-increment id from DB
  String date; // format: "yyyy-MM-dd", e.g. "2025-12-02"
  int steps;
  int calories;
  int water; // in ml

  Record({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  // Convert Dart object -> Map<String, dynamic> for SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };

    // Only include id if it’s not null (for updates)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  // Create a Record from a Map (row from SQLite)
  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as int?,
      date: map['date'] as String,
      steps: map['steps'] as int,
      calories: map['calories'] as int,
      water: map['water'] as int,
    );
  }
}
