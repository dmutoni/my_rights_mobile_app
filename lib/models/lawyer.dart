class Lawyer {
  final String id;
  final String name;
  final String organization;

  Lawyer({
    required this.id,
    required this.name,
    required this.organization,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'],
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
    );
  }
}