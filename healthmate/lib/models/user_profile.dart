class UserProfile {
  String username;
  String password;
  String name;
  String dob; // store as 'yyyy-MM-dd'
  int heightCm;
  double weightKg;
  bool hasDiabetes;
  bool hasCholesterol;
  String? profilePicturePath;

  UserProfile({
    required this.username,
    required this.password,
    required this.name,
    required this.dob,
    required this.heightCm,
    required this.weightKg,
    required this.hasDiabetes,
    required this.hasCholesterol,
    this.profilePicturePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'dob': dob,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'has_diabetes': hasDiabetes ? 1 : 0,
      'has_cholesterol': hasCholesterol ? 1 : 0,
      'profile_picture': profilePicturePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      dob: map['dob'] as String,
      heightCm: map['height_cm'] as int,
      weightKg: (map['weight_kg'] as num).toDouble(),
      hasDiabetes: (map['has_diabetes'] as int) == 1,
      hasCholesterol: (map['has_cholesterol'] as int) == 1,
      profilePicturePath: map['profile_picture'] as String?,
    );
  }
}
