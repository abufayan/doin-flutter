
class ProfileResponse {
  final String status;
  final String message; // Added message string
  final ProfileModel? data;

  ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileModel.fromJson(json['data']) : null,
    );
  }
}

class ProfileModel {
  final int id;
  final String username;
  final String email;
  final String whatsappNumber;
  final String? dateOfBirth;
  final String? nationality;
  final String? country;
  final String? address;
  final String? city;
  final int? referredById;
  final String? employmentStatus;
  final String? sourceOfIncome;
  final String? tradingExperience;
  final String? incomeRange;
  final String? occupation;
  final int profileCompleted;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.whatsappNumber,
    this.dateOfBirth,
    this.nationality,
    this.country,
    this.address,
    this.city,
    this.referredById,
    this.employmentStatus,
    this.sourceOfIncome,
    this.tradingExperience,
    this.incomeRange,
    this.occupation,
    required this.profileCompleted,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      dateOfBirth: json['date_of_birth'],
      nationality: json['nationality'],
      country: json['country'],
      address: json['address'],
      city: json['city'],
      referredById: json['referred_by_id'] is int
          ? json['referred_by_id']
          : int.tryParse(json['referred_by_id']?.toString() ?? ''),
      employmentStatus: json['employment_status'],
      sourceOfIncome: json['source_of_income'],
      tradingExperience: json['trading_experience'],
      incomeRange: json['income_range'],
      occupation: json['occupation'],
      profileCompleted: json['profile_completed'] ?? 0,
    );
  }
}

class SimpleResponse {
  final String status;
  final String message;

  SimpleResponse({
    required this.status,
    required this.message,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
