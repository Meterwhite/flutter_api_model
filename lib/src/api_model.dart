import 'package:meta/meta.dart';
import 'dart:async';

typedef APIModelCompletion<T> = void Function(T model);

typedef APIModelStateChange<T> = void Function(APIModelState state, T model);

enum APIModelState {
  ready,
  loading,
  blocked,
  completed,
}

/// Models network requests, managing input and output parameters,
/// following the "In-Out" naming convention. Supports mixin or extension.
///
/// Naming rules:
/// - The prefix for input parameters: `in`
///   (e.g., inUsername, inPassword)
/// - The prefix for return values: `out`
///   (e.g., outLoginUser)
///
/// There are three ways to define APIModel:
/// 1. Using mixin:
///    Suitable for cases without special initialization work.
///    ```dart
///    class SomeAPIModel with APIModel<SomeAPIModel>
///    ```
/// 2. Using inheritance:
///    Suitable for defining a base network request class that extends APIModel.
///    ```dart
///    class BaseAPIModel extends APIModel<SomeAPIModel>
///    ```
/// 3. Using a combination of mixin and inheritance (recommended):
///    Suitable for custom network requests, data processing, and separation of concerns.
///    For example, BaseRequest can handle Dio operations and data transformation,
///    while APIModel provides request flow and encapsulation.
///    ```dart
///    class SomeAPIModel extends BaseRequest with APIModel<SomeAPIModel>
///    ```
abstract mixin class APIModel<OwnerType> {
  APIModelStateChange<OwnerType>? onStateChanged;

  APIModelState get state => _state;

  APIModelCompletion<OwnerType>? _onComplete;

  APIModelState _state = APIModelState.ready;

  void _updateState(APIModelState newState) {
    _state = newState;
    onStateChanged?.call(_state, owner);
  }

  /// Starts the request.
  ///
  /// Example usage:
  /// ```dart
  /// model = await model.start();
  /// // or
  /// model.onCompletion((model) {
  ///   ...
  /// });
  /// ```
  /// If `throwOnError` is `true`, any exceptions caught during the request
  /// will be rethrown at the APIModel layer.
  @mustCallSuper
  Future<OwnerType> start({bool throwOnError = false}) async {
    if (_state != APIModelState.ready) {
      _updateState(APIModelState.ready);
    }
    if (hasPermission()) {
      if (hasError) {
        clearError();
      }
      willLoad();
      _updateState(APIModelState.loading);
      await load();
      if (throwOnError && hasError) {
        // Throw the latest exception if needed
        throw _errors.last!;
      }
      if (state != APIModelState.completed) {
        throw "Method 'finalize()' should be called";
      }
    } else {
      _updateState(APIModelState.blocked);
    }
    return Future.value(owner);
  }

  /// Registers a callback to be called when the request is completed.
  @mustCallSuper
  APIModel<OwnerType> onCompletion(APIModelCompletion<OwnerType>? callback) {
    _onComplete = callback;
    return this;
  }

  /// Registers a callback to be called when the state changes.
  @mustCallSuper
  APIModel<OwnerType> onStateChange(APIModelStateChange<OwnerType> callback) {
    onStateChanged = callback;
    return this;
  }

  /// Determines if the request has permission to proceed.
  /// If it returns `false`, the load() call will be blocked and the state will become `blocked`.
  /// Can be overridden using a mixin.
  bool hasPermission() {
    return true;
  }

  /// Called before the loading operation, typically changing the state to `APIModelState.ready`.
  @protected
  void willLoad() {}

  /// Completes all time-consuming tasks here;
  /// call `finalize()` when the model is complete, and you may call it multiple times.
  /// Any exception and error thrown can be recorded to `outError`,
  /// `outError` is a List type.
  @visibleForOverriding
  Future<void> load();

  /// Called after the loading operation, typically changing the state to `APIModelState.completed`.
  @protected
  void didLoad() {}

  /// Call this when the request is completed.
  /// If this method is not called, an exception will be thrown.
  @protected
  void finalize() {
    _updateState(APIModelState.completed);
    didLoad();
    _onComplete?.call(owner);
  }

  /// Retrieves the object of the type that implements the final functionality.
  /// The type of Owner must exactly match the type that implements the APIModel.
  @useResult
  OwnerType get owner {
    if (this is! OwnerType) {
      throw TypeError();
    }
    return this as OwnerType;
  }
 
  // -------------  Error  --------------
  
  bool get hasError => _errors.isNotEmpty;

  List get allError => _errors;

  final List _errors = [];

  /// Clears all errors.
  @protected
  void clearError() => _errors.clear();
}
