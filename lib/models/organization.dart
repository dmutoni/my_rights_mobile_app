class Organization {
  final String id;
  final String name;
  final String location;
  final String type;

  Organization({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
    );
  }
}