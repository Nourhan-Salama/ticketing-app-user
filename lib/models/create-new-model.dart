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


  @override
  String toString() {
    return 'Ticket(firstName: $firstName, lastName: $lastName, email: $email)';
  }
}
