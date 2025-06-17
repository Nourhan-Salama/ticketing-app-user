class SectionModel {
  final int id;
  final String name;
  final int serviceId;

  SectionModel({
    required this.id,
    required this.name,
    required this.serviceId,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      serviceId: json['service_id'] as int,
    );
  }

  factory SectionModel.empty() => SectionModel(
        id: -1,
        name: '',
        serviceId: -1,
      );

  @override
  String toString() => name;
}