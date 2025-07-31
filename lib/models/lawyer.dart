class Lawyer {
  final String id;
  final String name;
  final List<String> organizations;
  final String? profileImageUrl;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final List<String>? specializations;
  final bool isAvailable;
  final double? rating;
  final int? experienceYears;
  
  // Additional fields for the detail screen
  final String? about; // Custom about text
  final String? title; // Professional title (e.g., "Senior Legal Counsel", "Legal Aid Lawyer")
  final String? barAdmission; // Bar admission info
  final String? education; // Educational background
  final List<String>? languages; // Languages spoken
  final List<String>? certifications; // Additional certifications
  final String? workingHours; // Working hours or availability
  final DateTime? joinedDate; // When they joined the organization
  final bool? isVerified; // Verification status
  final String? licenseNumber; // Bar license number
  final List<String>? achievements; // Awards or recognitions

  Lawyer({
    required this.id,
    required this.name,
    required this.organizations,
    this.profileImageUrl,
    this.email,
    this.phoneNumber,
    this.address,
    this.specializations,
    this.isAvailable = true,
    this.rating,
    this.experienceYears,
    // New fields
    this.about,
    this.title,
    this.barAdmission,
    this.education,
    this.languages,
    this.certifications,
    this.workingHours,
    this.joinedDate,
    this.isVerified,
    this.licenseNumber,
    this.achievements,
  });

  // Factory constructor for JSON parsing
  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      organizations: json['organizations'] != null 
          ? List<String>.from(json['organizations'])
          : [],
      profileImageUrl: json['profileImageUrl']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      specializations: json['specializations'] != null 
          ? List<String>.from(json['specializations'])
          : null,
      isAvailable: json['isAvailable'] ?? true,
      rating: json['rating']?.toDouble(),
      experienceYears: json['experienceYears']?.toInt(),
      // New fields parsing
      about: json['about']?.toString(),
      title: json['title']?.toString(),
      barAdmission: json['barAdmission']?.toString(),
      education: json['education']?.toString(),
      languages: json['languages'] != null 
          ? List<String>.from(json['languages'])
          : null,
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications'])
          : null,
      workingHours: json['workingHours']?.toString(),
      joinedDate: json['joined_date'] != null 
          ? DateTime.tryParse(json['joined_date'].toString())
          : null,
      isVerified: json['isVerified'],
      licenseNumber: json['licenseNumber']?.toString(),
      achievements: json['achievements'] != null 
          ? List<String>.from(json['achievements'])
          : null,
    );
  }
}
