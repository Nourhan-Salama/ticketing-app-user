class VerificationModel {
  final String handle;
  final String code;
  VerificationModel({required this.handle, required this.code});
  Map<String, dynamic> toJson() {
    return {
      "handle": handle,
      "code": code,
    };
  }
}
