import 'package:flutter/material.dart';
import 'dart:async';

typedef APIModelCompletion<T> = Function(T model);

typedef APIModelStateChange<T> = Function(APIModelState state, T model);

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
///
/// - The prefix for return values: `out`
///   (e.g., outLoginUser)
abstract mixin class APIModel<T> {
  APIModelStateChange<T>? onStateChanged;

  APIModelState get state => _state;

  bool get hasError => outErrors.isNotEmpty;

  /// Returns the last error if any.
  dynamic get outError => outErrors.isNotEmpty ? outErrors.last : null;

  final List outErrors = [];

  APIModelCompletion<T>? _onComplete;

  APIModelState _state = APIModelState.ready;

  void _updateState(APIModelState newState) {
    _state = newState;
    onStateChanged?.call(_state, model);
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
  Future<T> start({bool throwOnError = false}) async {
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
        throw outError!;
      }
      if (state != APIModelState.completed) {
        throw "Method 'finalize()' should be called";
      }
    } else {
      _updateState(APIModelState.blocked);
    }
    return Future.value(model);
  }

  /// Registers a callback to be called when the request is completed.
  @mustCallSuper
  APIModel<T> onCompletion(APIModelCompletion<T>? callback) {
    _onComplete = callback;
    return this;
  }

  /// Registers a callback to be called when the state changes.
  APIModel<T> onStateChange(APIModelStateChange<T> callback) {
    onStateChanged = callback;
    return this;
  }

  /// Determines if the request has permission to proceed.
  /// If it returns `false`, the load() call will be blocked and the state will become `blocked`.
  /// Can be overridden using a mixin.
  @protected
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
  @protected
  Future<void> load();

  /// Called after the loading operation, typically changing the state to `APIModelState.completed`.
  @protected
  void didLoad() {}

  /// Call this when the request is completed.
  /// If this method is not called, an exception will be thrown.
  @mustCallSuper
  @protected
  void finalize() {
    _updateState(APIModelState.completed);
    didLoad();
    _onComplete?.call(model);
  }

  /// Retrieves the model instance.
  /// Can be overridden using a mixin.
  T get model {
    if (this is! T) {
      throw TypeError();
    }
    return this as T;
  }

  /// Assigns an error to `outError`. Assigning null is invalid.
  @protected
  set outError(dynamic error) {
    if (error != null) {
      outErrors.add(error);
    }
  }

  /// Clears all errors.
  @protected
  void clearError() => outErrors.clear();
}
