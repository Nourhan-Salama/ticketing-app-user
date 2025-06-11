class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final int type; // 0 = text, 1 = image, 2 = video, 3/4 = audio, 5 = document, 6 = location
  final String? mediaUrl;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.type,
    this.mediaUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'] ?? '',
      senderId: json['sender']['id'],
      timestamp: DateTime.parse(json['created_at']),
      type: json['type'],
      mediaUrl: json['media'],
    );
  }

  /// Checks whether this message is plain text.
  bool get isText => type == 0;

  /// Checks whether this message contains any media (image, video, audio, etc.).
  bool get isMedia => type != 0;

  /// Specific media types
  bool get isImage => type == 1;
  bool get isVideo => type == 2;
  bool get isAudio => type == 3 || type == 4;
  bool get isDocument => type == 5;
  bool get isLocation => type == 6;
}
