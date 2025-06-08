class ServiceModel {
  final int id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
    factory ServiceModel.empty() => ServiceModel(id: -1, name: '');

  @override
  String toString() => name;
}
