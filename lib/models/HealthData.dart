class HealthData {
  final String id;
  final String userId;
  final int steps;
  final int calories;
  final int water;
  final int sleep;
  final DateTime date;

  HealthData({
    required this.id,
    required this.userId,
    this.steps = 0,
    this.calories = 0,
    this.water = 0,
    this.sleep = 0,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'steps': steps,
    'calories': calories,
    'water': water,
    'sleep': sleep,
    'date': date.toIso8601String(),
  };

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    steps: json['steps'] ?? 0,
    calories: json['calories'] ?? 0,
    water: json['water'] ?? 0,
    sleep: json['sleep'] ?? 0,
    date: json['date'] != null 
        ? DateTime.parse(json['date']) 
        : DateTime.now(),
  );

  HealthData copyWith({
    String? id,
    String? userId,
    int? steps,
    int? calories,
    int? water,
    int? sleep,
    DateTime? date,
  }) {
    return HealthData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
      sleep: sleep ?? this.sleep,
      date: date ?? this.date,
    );
  }
}