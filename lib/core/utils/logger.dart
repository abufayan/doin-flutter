/// Centralized logging utility for the application
class AppLogger {
  /// Log info level messages
  static void info(String message, {String? tag}) {
    // Silence
  }

  /// Log warning level messages
  static void warning(String message, {String? tag}) {
    // Silence
  }

  /// Log error level messages with optional stack trace
  static void error(
    String message, {
    String? tag,
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    // Silence (TODO: Send to crash reporting service)
  }

  /// Log API requests (without sensitive data)
  static void apiRequest(
    String method,
    String url, {
    Map<String, dynamic>? params,
  }) {
    // Silence
  }

  /// Log API responses (without sensitive data)
  static void apiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic responseData,
  }) {
    // Silence
  }

  /// Log API errors
  static void apiError(
    String method,
    String url,
    int? statusCode, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // Silence
  }

  /// Log authentication events
  static void auth(String message) {
    // Silence
  }
}
