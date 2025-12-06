class DailyRecord {
  int? recordId;
  String username;
  String date; // 'yyyy-MM-dd'
  int steps;
  int waterMl;
  int calorieIntake;

  DailyRecord({
    this.recordId,
    required this.username,
    required this.date,
    required this.steps,
    required this.waterMl,
    required this.calorieIntake,
  });

  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'username': username,
      'date': date,
      'steps': steps,
      'water_ml': waterMl,
      'calorie_intake': calorieIntake,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      recordId: map['record_id'] as int?,
      username: map['username'] as String,
      date: map['date'] as String,
      steps: map['steps'] as int,
      waterMl: map['water_ml'] as int,
      calorieIntake: map['calorie_intake'] as int,
    );
  }
}
