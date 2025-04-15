class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": "$firstName $lastName",  
      "email": email,
      "password": password,
      "password_confirmation": confirmPassword,
    };
  }
}

