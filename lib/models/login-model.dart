class LoginRequest {
  final String handle;
  final String password;

  LoginRequest({required this.handle, required this.password});


  Map<String, dynamic> toJson() {
    return {
      "handle": handle,
      "password": password,
    };
  }
}
