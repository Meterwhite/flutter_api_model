import 'package:flutter_api_model/flutter_api_model.dart';

/// Provides enhanced error management capabilities, including the `outError` property and a generic `ErrorType`.
/// For example:
/// ```dart
/// MyAPIModel with OutError<MyAPIModel, MyError>
/// ```
mixin OutError<OwnerType, ErrorType> on APIModel<OwnerType> {

  /// Gets the list of errors filtered by the specified `ErrorType`.
  List<ErrorType> get outErrors => allError.whereType<ErrorType>().toList();

  /// Returns the last error of the specified `ErrorType`, if any.
  ErrorType? get outError => allError.isNotEmpty ? allError.last : null;

  /// Sets the last error. Assigning null is invalid.
  set outError(ErrorType? error) {
    if (error != null) {
      allError.add(error);
    }
  }
}
