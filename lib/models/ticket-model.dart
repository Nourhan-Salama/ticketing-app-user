

import 'package:final_app/models/section-model.dart';
import 'package:final_app/models/service-model.dart';

class TicketModel {
  final int id;
  final String title;
  final int status;
  final String description;
  final ServiceModel service;
  final DateTime createdAt;
  final UserModel user;
  final ManagerModel? manager;
  final TechnicianModel? technician;
  final SectionModel? section;

  TicketModel({
    required this.createdAt,
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.service,
    required this.user,
    this.manager,
    this.technician,
    this.section,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'] as String,
      status: json['status'] as int,
      description: json['description'] as String,
      // Fixed: Access service through section
      service: ServiceModel.fromJson(json['section']['service']),
      user: UserModel.fromJson(json['user']),
      manager: json['manager'] != null ? ManagerModel.fromJson(json['manager']) : null,
      technician: json['technician'] != null ? TechnicianModel.fromJson(json['technician']) : null,
      section: json['section'] != null ? SectionModel.fromJson(json['section']) : null,
    );
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ManagerModel {
  final int id;
  final bool automaticAssignment;
  final UserModel user;

  ManagerModel({
    required this.id,
    required this.automaticAssignment,
    required this.user,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['id'] as int,
      automaticAssignment: json['automatic_assignment'] as bool,
      user: UserModel.fromJson(json['user']),
    );
  }
}

class TechnicianModel {
  final int id;
  final UserModel user;

  TechnicianModel({required this.id, required this.user});

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user']),
    );
  }}