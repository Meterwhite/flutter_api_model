/// Custom exception class for APIModel errors.
class APIModelException implements Exception {
  final String message;
  APIModelException(this.message);

  @override
  String toString() => 'APIModelException: $message';
}
