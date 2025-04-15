class Message {
  final String message;
  final String id;
  final DateTime time;  

  Message({
    required this.message,
    required this.id,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> jsonData) {
    return Message(
      message: jsonData['message'] ?? "", 
      id: jsonData['id'] ?? "",
      time: DateTime.fromMillisecondsSinceEpoch(jsonData['time'] ?? 0), 
    );
  }
}
