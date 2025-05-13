class UserTargets {
  final String userId;
  final int dailyStepsTarget;
  final int dailyCaloriesTarget;
  final int dailyWaterTarget;
  final int dailySleepTarget;

  UserTargets({
    required this.userId,
    required this.dailyStepsTarget,
    required this.dailyCaloriesTarget,
    required this.dailyWaterTarget,
    required this.dailySleepTarget,
  });

  Map<String, dynamic> toJson() => {
    'dailyStepsTarget': dailyStepsTarget,
    'dailyCaloriesTarget': dailyCaloriesTarget,
    'dailyWaterTarget': dailyWaterTarget,
    'dailySleepTarget': dailySleepTarget,
  };

  factory UserTargets.fromJson(Map<String, dynamic> json) => UserTargets(
    userId: json['userId'],
    dailyStepsTarget: json['dailyStepsTarget'],
    dailyCaloriesTarget: json['dailyCaloriesTarget'],
    dailyWaterTarget: json['dailyWaterTarget'],
    dailySleepTarget: json['dailySleepTarget'],
  );
}