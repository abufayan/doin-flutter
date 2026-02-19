class WithdrawApiResponse {
  final String status;
  final String message;
  final String? error;

  WithdrawApiResponse({
    required this.status,
    required this.message,
    this.error,
  });

  factory WithdrawApiResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      error: json['error'] as String?,
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}