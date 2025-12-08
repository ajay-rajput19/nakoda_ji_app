class BackendResponse {
  final bool success;
  final String message;
  final dynamic data;
  final String? detail;

  BackendResponse({
    required this.success,
    required this.message,
    this.data,
    this.detail,
  });

  factory BackendResponse.fromJson(Map<String, dynamic> json) {
    return BackendResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      detail: json['detail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'detail': detail,
    };
  }

  bool isSuccess() {
    return success;
  }

  static String get successMsg => 'success';

  String errorDetail(String? fallbackMessage) {
    if (detail != null) {
      return detail!;
    }
    return fallbackMessage ?? 'An error occurred';
  }
}