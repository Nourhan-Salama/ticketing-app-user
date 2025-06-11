class MessageModel {
  final String id;
  final String content;
  final String senderId;
    final DateTime createdAt; 

  final int type; // 0 = text, 1 = image, 2 = video, 3/4 = audio, 5 = document, 6 = location
  final String? mediaUrl;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  
    required this.type,
    this.mediaUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Better media URL extraction with debugging
    String? extractedMediaUrl;
    
    print('Raw JSON for message: $json'); // Debug log
    
    if (json['media'] != null) {
      print('Media field found: ${json['media']}'); // Debug log
      
      if (json['media'] is String) {
        extractedMediaUrl = json['media'];
        print('Media is string: $extractedMediaUrl'); // Debug log
      } else if (json['media'] is Map) {
        // Handle cases where media is an object
        final mediaMap = json['media'] as Map<String, dynamic>;
        print('Media is map: $mediaMap'); // Debug log
        
        extractedMediaUrl = mediaMap['url'] ?? 
                           mediaMap['path'] ?? 
                           mediaMap['file_path'] ??
                           mediaMap['name'];
        print('Extracted from map: $extractedMediaUrl'); // Debug log
      }
    } else {
      print('No media field found in JSON'); // Debug log
    }

    // Also check for other possible media field names
    if (extractedMediaUrl == null) {
      extractedMediaUrl = json['media_url'] ?? 
                         json['file_url'] ?? 
                         json['image_url'] ??
                         json['attachment'];
      if (extractedMediaUrl != null) {
        print('Found media in alternative field: $extractedMediaUrl');
      }
    }

    final message = MessageModel(
      
      id: json['id'].toString(),
      content: json['content'] ?? '',
      
      senderId: json['sender']?['id']?.toString() ?? 
               json['user']?['id']?.toString() ?? '',
      
      createdAt: DateTime.parse(json['created_at']),
      type: json['type'] is int ? json['type'] : 0,
      
      mediaUrl: extractedMediaUrl,
    );
    
    print('Final message created: $message'); // Debug log
    return message;
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

  @override
  String toString() {
    return 'MessageModel{id: $id, type: $type, senderId: $senderId, mediaUrl: $mediaUrl, content: ${content.length > 50 ? content.substring(0, 50) + "..." : content}}';
  }
}