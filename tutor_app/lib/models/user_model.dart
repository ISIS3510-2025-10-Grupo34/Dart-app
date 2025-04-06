class User {
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? university;
  String? major;
  String? areaOfExpertise;
  String isAdmin = "false";
  String isStudent = "false";
  String isTutor = "false";
  String? learningStyles;
  String? profilePicturePath;
  String? idPicturePath;
  String? password;
  String? role;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.university,
    this.major,
    this.areaOfExpertise,
    this.isAdmin = "false",
    this.isStudent = "false",
    this.isTutor = "false",
    this.learningStyles,
    this.profilePicturePath,
    this.idPicturePath,
    this.password,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'university': university,
      'major': major,
      'area_of_expertise': areaOfExpertise,
      'is_admin': isAdmin,
      'is_student': isStudent,
      'is_tutor': isTutor,
      'learning_styles': learningStyles,
      'password': password,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
    );
  }
}
