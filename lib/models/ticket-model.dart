// ticket-model.dart
import 'package:flutter/material.dart';

class TicketModel {
  final DateTime createdAt;
  final String department;
  final String email;
  final String description;
  final String firstName;
  final String lastName;
  final String status;
  final Color statusColor;

   String get userName => '$firstName $lastName';
   
  TicketModel({
    DateTime? createdAt,
    required this.department,
    required this.email,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.statusColor,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      createdAt: DateTime.parse(map['createdAt']),
      department: map['department'],
      email: map['email'],
      description: map['description'],
      firstName: map['firstName'],
       lastName: map['lastName'],
      status: map['status'],
      statusColor: Color(map['statusColor']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'department': department,
      'email': email,
      'description': description,
      'firstName': firstName,
      'lastName': lastName,
      'status': status,
      'statusColor': statusColor.value,
    };
  }
}
