import 'package:meta/meta.dart';
import 'exception.dart';
import 'dart:async';

typedef APIModelCallback<T> = void Function(T model);

typedef APIModelStateChange<T> = void Function(APIModelState state, T model);

/// Represents the state of a request object.
enum APIModelState {
  /// Indicates the request is in a state where it has not yet started and is ready to be prepared.
  ready,

  /// Indicates the request is currently executing the `load()` method.
  loading,

  /// Indicates the request has been blocked.
  blocked,

  /// Indicates the request has completed as per the user's specified flow.
  completed,

  /// Indicates the request has been canceled.
  canceled,
}

/// High-level modeling of network requests, managing input and output parameters,
/// adhering to the "In-Out" naming convention. Supports mixin or extension.
///
/// **Naming rules:**
/// - Input parameters prefix: `in`
///   (e.g., `inUsername`, `inPassword`)
/// - Return values prefix: `out`
///   (e.g., `outLoginUser`)
///
/// **Ways to define APIModel:**
/// 1. **Using mixin:**
///    Suitable for cases without special initialization work.
///    ```dart
///    class SomeAPIModel with APIModel<SomeAPIModel>
///    ```
/// 2. **Using inheritance:**
///    Suitable for defining a base network request class that extends APIModel.
///    ```dart
///    class BaseAPIModel extends APIModel<SomeAPIModel>
///    ```
/// 3. **Using a combination of mixin and inheritance (recommended):**
///    Suitable for custom network requests, data processing, and separation of concerns.
///    For example, BaseRequest can handle Dio operations and data transformation,
///    while APIModel provides request flow and encapsulation.
///    ```dart
///    class SomeAPIModel extends BaseRequest with APIModel<SomeAPIModel>
///    ```
abstract mixin class APIModel<OwnerType> {
  /// Indicates whether there is an error after the current request is completed.
  bool get hasError => _errors.isNotEmpty;

  /// Indicates whether the current request is blocked.
  /// Implemented by the `hasPermission()` method.
  bool get isBlocked => _state == APIModelState.blocked;

  APIModelState get state => _state;

  APIModelStateChange<OwnerType>? stateChangeHandler;

  APIModelCallback<OwnerType>? completionHandler;

  APIModelCallback<OwnerType>? blockedHandler;

  APIModelState _state = APIModelState.ready;

  void _updateState(APIModelState newState) {
    _state = newState;
    stateChangeHandler?.call(_state, owner);
  }

  /// Starts the request.
  ///
  /// **Example usage:**
  /// ```dart
  /// model = await model.start();
  /// // or
  /// model.onComplete((model) {
  ///   ...
  /// });
  /// ```
  /// If `throwOnError` is `true`, any exceptions caught during the request
  /// will be rethrown at the APIModel layer.
  @mustCallSuper
  Future<OwnerType> start({bool throwOnError = false}) async {
    if (_state != APIModelState.ready) {
      clear();
    }
    if (hasPermission()) {
      willLoad();
      _updateState(APIModelState.loading);
      await load();
      if (throwOnError && hasError) {
        // Throw the latest exception if needed
        throw _errors.last!;
      }
      if (state != APIModelState.completed || state != APIModelState.canceled) {
        throw APIModelException("Method 'finalize()' should be called.");
      }
    } else {
      // Block API
      _updateState(APIModelState.blocked);
      didBlock();
      blockedHandler?.call(owner);
    }
    return Future.value(owner);
  }

  /// Registers a callback to be called when the state changes.
  @mustCallSuper
  APIModel<OwnerType> onStateChange(APIModelStateChange<OwnerType> callback) {
    stateChangeHandler = callback;
    return this;
  }

  /// Registers a callback to be called when the request is completed.
  @mustCallSuper
  APIModel<OwnerType> onComplete(APIModelCallback<OwnerType>? callback) {
    completionHandler = callback;
    return this;
  }

  /// Registers a callback to be called when the request is blocked.
  @mustCallSuper
  APIModel<OwnerType> onBlocked(APIModelCallback<OwnerType> callback) {
    blockedHandler = callback;
    return this;
  }

  /// Determines if the request has permission to proceed.
  /// If it returns `false`, the `load()` call will be blocked and the state will become `blocked`.
  /// Can be overridden using a mixin.
  bool hasPermission() {
    return true;
  }

  /// Clears all In-Out parameters. This behavior is valuable for reusable objects.
  @mustCallSuper
  void clear() {
    _updateState(APIModelState.ready);
    clearError();
  }

  /// Override to implement unified handling of blocked objects.
  @protected
  void didBlock() {}

  /// Called before the loading operation, typically changing the state to `APIModelState.loading`.
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
    if (_state == APIModelState.loading) {
      _updateState(APIModelState.completed);
      didLoad();
    } else if (_state == APIModelState.canceled) {
      didCancel();
    }
    completionHandler?.call(owner);
  }

  /// Override or mix in the methods `isCancellable()` and `cancel()` to support canceling requests.
  @protected
  bool isCancellable() {
    return false;
  }

  /// Override or mix in the methods `isCancellable()` and `cancel()` to support canceling requests.
  /// Implement the cancellation logic here.
  @mustCallSuper
  void cancel() {
    if (isCancellable()) {
      _updateState(APIModelState.canceled);
    } else {
      throw APIModelException('Cancellation not allowed');
    }
  }

  /// Called after the cancel operation.
  @protected
  void didCancel() {}

  /// Retrieves the object of the type that implements the final functionality.
  /// The type of Owner must exactly match the type that implements the APIModel.
  @useResult
  OwnerType get owner {
    if (this is! OwnerType) {
      throw APIModelException('The object is not of type OwnerType.');
    }
    return this as OwnerType;
  }

  // -------------  Error  --------------

  List get allError => _errors;

  final List _errors = [];

  /// Clears all errors.
  @protected
  void clearError() => _errors.clear();
}
