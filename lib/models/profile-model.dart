class ProfileModel {
  final int id;
  final String name; 
  final String email;
  final String? phone;
  final String?avatar;
  final int type;
  final DateTime createdAt;
  final DateTime? lastLoginTime;
  final bool status;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
   this.avatar,
    required this.type,
    required this.createdAt,
    required this.lastLoginTime,
    required this.status,
  });

  // ✅ Add computed firstName and lastName
  String get firstName {
    return name.split(' ').first;
  }

  String get lastName {
    final parts = name.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      lastLoginTime: json['last_login_time'] != null
          ? DateTime.parse(json['last_login_time'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'last_login_time': lastLoginTime?.toIso8601String(),
      'status': status,
    };
  }
}
