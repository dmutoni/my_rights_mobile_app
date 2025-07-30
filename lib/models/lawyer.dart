
class Lawyer {
  final String id;
  final String name;
  final String organization;
  final String? profileImageUrl;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final List<String>? specializations;
  final bool isAvailable;
  final double? rating;
  final int? experienceYears;

  Lawyer({
    required this.id,
    required this.name,
    required this.organization,
    this.profileImageUrl,
    this.email,
    this.phoneNumber,
    this.address,
    this.specializations,
    this.isAvailable = true,
    this.rating,
    this.experienceYears,
  });

  // Factory constructor for JSON parsing
  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      organization: json['organization']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      specializations: json['specializations'] != null 
          ? List<String>.from(json['specializations'])
          : null,
      isAvailable: json['is_available'] ?? true,
      rating: json['rating']?.toDouble(),
      experienceYears: json['experience_years']?.toInt(),
    );
  }
}