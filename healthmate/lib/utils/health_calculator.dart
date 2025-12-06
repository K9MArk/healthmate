class HealthCalculator {
  static double bmi(double weightKg, int heightCm) {
    final h = heightCm / 100.0;
    if (h <= 0) return 0;
    return weightKg / (h * h);
  }

  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  static String bmiMessage(String cat) {
    switch (cat) {
      case 'Underweight':
        return 'BMI below normal range. Consider balanced meals and professional advice.';
      case 'Normal':
        return 'BMI in normal range. Keep up regular activity and balanced diet.';
      case 'Overweight':
        return 'BMI above normal range. More daily movement + reduce sugary/fatty foods.';
      default:
        return 'BMI high. Gradual lifestyle changes help. Consider professional guidance.';
    }
  }

  static int ageFromDob(String dobIso) {
    // dob in 'yyyy-MM-dd'
    try {
      final dob = DateTime.parse(dobIso);
      final now = DateTime.now();
      var age = now.year - dob.year;
      final hasHadBirthday = (now.month > dob.month) ||
          (now.month == dob.month && now.day >= dob.day);
      if (!hasHadBirthday) age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  static double baseCalories(double weightKg) => weightKg * 30.0;
  static double caloriesFromSteps(int steps) => steps * 0.04;
  static double totalBurned(double weightKg, int steps) =>
      baseCalories(weightKg) + caloriesFromSteps(steps);
  static double netCalories(int intake, double totalBurned) =>
      intake - totalBurned;

  static double progress(int value, int goal) {
    if (goal <= 0) return 0;
    return (value / goal) * 100.0;
  }

  static String stepsMessage(double percent) {
    if (percent < 40) return 'Low activity today, try a short walk.';
    if (percent < 80) return 'Good movement, keep going!';
    return 'Great job, very active today!';
  }

  static String waterMessage(double percent) {
    if (percent < 50) return 'Hydration is low, drink more water.';
    if (percent < 100) return 'Almost at your water goal.';
    return 'Hydration goal reached!';
  }

  static String caloriesMessage(double net) {
    if (net < -300) return 'Calorie deficit today (may support weight loss).';
    if (net <= 300) return 'Near maintenance today.';
    return 'Calorie surplus today (may lead to weight gain over time).';
  }

  static String conditionTip(
      {required bool diabetes, required bool cholesterol}) {
    if (diabetes && cholesterol) {
      return 'Tips: stay active, avoid sugary drinks, and reduce fried/processed foods.';
    } else if (diabetes) {
      return 'Diabetes tip: avoid sugary drinks and keep regular meals.';
    } else if (cholesterol) {
      return 'Cholesterol tip: reduce fried/processed foods; choose grilled/baked.';
    }
    return '';
  }
}
