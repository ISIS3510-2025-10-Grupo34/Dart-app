class TimeToBookInsight {
  final String message;

  TimeToBookInsight({required this.message});

  factory TimeToBookInsight.fromJson(Map<String, dynamic> json) {
    return TimeToBookInsight(
      message: json['message'] ?? '',
    );
  }
}
