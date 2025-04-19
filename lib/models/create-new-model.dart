class CreateTicketModel {
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final String description;

  CreateTicketModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.description,
  });

  /// Converts the model to JSON to send to API
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'department': department,
      'description': description,
    };
  }

  /// Optional: From JSON (if backend returns the same structure)
  // factory CreateTicketModel.fromJson(Map<String, dynamic> json) {
  //   return CreateTicketModel(
  //     firstName: json['first_name'],
  //     lastName: json['last_name'],
  //     email: json['email'],
  //     department: json['department'],
  //     description: json['description'],
  //   );
  // }

  /// Optional: override toString for easier debug
  @override
  String toString() {
    return 'Ticket(firstName: $firstName, lastName: $lastName, email: $email)';
  }
}
