/// Provides enhanced error management capabilities:
/// includes the `outError` property and a generic `ErrorType`.
mixin OutError<ErrorType> {
  List get allError;

  List<ErrorType> get outErrors => allError.whereType<ErrorType>().toList();

  /// Returns the last error if any.
  ErrorType? get outError => allError.isNotEmpty ? allError.last : null;

  /// Assigns an error to `outError`. Assigning null is invalid.
  set outError(ErrorType? error) {
    if (error != null) {
      allError.add(error);
    }
  }
}
