import 'package:flutter/foundation.dart';

enum NotificationType {
  systemNotification,
  ticketCreated,
  ticketUpdated,
  ticketAssigned,
  ticketResolved,
  chat,
  unknown;

  factory NotificationType.fromString(String type) {
    switch (type) {
      case 'system_notification':
        return NotificationType.systemNotification;
      case 'ticket_created':
        return NotificationType.ticketCreated;
      case 'ticket_updated':
        return NotificationType.ticketUpdated;
      case 'ticket_assigned':
        return NotificationType.ticketAssigned;
      case 'ticket_resolved':
        return NotificationType.ticketResolved;
      case 'chat':
        return NotificationType.chat;
      default:
        return NotificationType.unknown;
    }
  }

  String get displayName {
    return toString().split('.').last.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim();
  }
}

class NotificationModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool seen;
  final String body;
  final NotificationData data;
  final bool read;

  NotificationModel({
    required this.read,
    required this.id,
    required this.title,
    required this.createdAt,
    required this.seen,
    required this.body,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['id'] ?? '',
        title: json['title'] ?? 'No Title',
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
        seen: json['seen'] ?? false,
        body: json['body'] ?? '',
        data: NotificationData.fromJson(json['data'] ?? {}),
        read: json['read'] ?? false,
      );
    } catch (e) {
      debugPrint('Error parsing NotificationModel: $e');
      rethrow;
    }
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    bool? seen,
    String? body,
    NotificationData? data,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      seen: seen ?? this.seen,
      body: body ?? this.body,
      data: data ?? this.data,
      read: read ?? this.read,
    );
  }
}

class NotificationData {
  final NotificationType type;
  final int modelId;

  NotificationData({
    required this.type,
    required this.modelId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      type: NotificationType.fromString(json['type'] ?? 'unknown'),
      modelId: json['model_id'] ?? 0,
    );
  }

  NotificationData copyWith({
    NotificationType? type,
    int? modelId,
  }) {
    return NotificationData(
      type: type ?? this.type,
      modelId: modelId ?? this.modelId,
    );
  }
}