// ticket-model.dart
import 'package:flutter/material.dart';

class TicketModel {
  final String description;
  final String userName;
  final String status;
  final Color statusColor;

  TicketModel({
    required this.description,
    required this.userName,
    required this.status,
    required this.statusColor,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      description: map['description'] as String,
      userName: map['userName'] as String,
      status: map['status'] as String,
      statusColor: Color(map['statusColor'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'userName': userName,
      'status': status,
      'statusColor': statusColor.value,
    };
  }
}

