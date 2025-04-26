class NotificationModel {
  final String title;
  final String message;
  final String place;
  final String university;
  final DateTime date;

  NotificationModel({
    required this.title,
    required this.message,
    required this.place,
    required this.university,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'],
      place: json['place'],
      university: json['university'],
      date: DateTime.parse(json['date']),
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'title': title,
    'message': message,
    'place': place,
    'university': university,
    'date': date.toIso8601String(), 
  };
}

}
