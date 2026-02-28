class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
