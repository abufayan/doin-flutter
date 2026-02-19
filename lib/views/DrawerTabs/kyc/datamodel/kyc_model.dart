import 'package:flutter/material.dart';

class KycApiResponse {
  final String status;
  final String message;

  KycApiResponse({required this.status, required this.message});

  factory KycApiResponse.fromJson(Map<String, dynamic> json) {
    return KycApiResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Something went wrong',
    );
  }
}

@immutable
class KycResponse {
  final int id;
  final String? photo_id_1_status;
  final String? photo_id_2_status;
  final String? photo_id_3_status;

  const KycResponse({
    required this.id,
    this.photo_id_1_status,
    this.photo_id_2_status,
    this.photo_id_3_status,
  });

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      id: json['id'] as int? ?? 0,
      photo_id_1_status: json['photo_id_1_status'] as String?,
      photo_id_2_status: json['photo_id_2_status'] as String?,
      photo_id_3_status: json['photo_id_3_status'] as String?,
    );
  }

  /// Normalized status for comparison (lowercase, null preserved)
  static String? _normalize(String? s) => s?.trim().toLowerCase();

  /// Whether this slot can be (re)uploaded: null = not submitted, rejected = can re-upload
  static bool canUpload(String? status) {
    final s = _normalize(status);
    return s == null || s == 'rejected';
  }

  /// Whether this slot is locked (pending or approved)
  static bool isLocked(String? status) {
    final s = _normalize(status);
    return s == 'pending' || s == 'approved';
  }

  /// Display label for status
  static String statusLabel(String? status) {
    final s = _normalize(status);
    if (s == null) return 'Not submitted';
    if (s == 'pending') return 'Pending';
    if (s == 'approved') return 'Approved';
    if (s == 'rejected') return 'Rejected';
    return s;
  }

  /// ✅ Helper: checks if ALL photos are approved
  bool get isApproved =>
      _normalize(photo_id_1_status) == 'approved' &&
      _normalize(photo_id_2_status) == 'approved' &&
      _normalize(photo_id_3_status) == 'approved';
}
