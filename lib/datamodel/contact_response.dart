class ContactResponse {
  final String message;
  final List<ContactData> data;

  ContactResponse({required this.message, required this.data});

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)
              ?.map((e) => ContactData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ContactData {
  final String description;
  final String whatsappNumber;
  final String email;

  ContactData({
    required this.description,
    required this.whatsappNumber,
    required this.email,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      description: json['description'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
