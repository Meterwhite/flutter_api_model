import 'package:flutter/material.dart';
import 'dart:async';

typedef RequestModelCompletion<T> = Function(T model);

typedef RequestModelStateChange<T> = Function(RequestModelState state, T model);

enum RequestModelState {
  ready,
  loading,
  loadingBlocked,
  complete,
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
abstract mixin class RequestModel<T> {
  RequestModelStateChange<T>? onStateChanged;

  RequestModelState get state => _state;

  bool get hasError => outErrors.isNotEmpty;

  /// Returns the last error if any.
  dynamic get outError => outErrors.isNotEmpty ? outErrors.last : null;

  final List outErrors = [];

  RequestModelCompletion<T>? _userCompletion;

  RequestModelState _state = RequestModelState.ready;

  void _updateState(RequestModelState newState) {
    _state = newState;
    onStateChanged?.call(_state, model);
  }

  /// Starts the request.
  ///
  /// Example usage:
  /// ```dart
  /// model = await model.execute();
  /// // or
  /// model.onComplete((model) {
  ///   ...
  /// });
  /// ```
  Future<T> execute({
    dynamic userinfo,
    bool throwError = false,
  }) async {
    if (_state != RequestModelState.ready) {
      _updateState(RequestModelState.ready);
    }
    if (hasPermission()) {
      if (hasError) {
        clearError();
      }
      willLoad();
      _updateState(RequestModelState.loading);
      await loading();
      if (throwError && hasError) {
        // Throw the latest exception if needed
        throw outError!;
      }
      if (state != RequestModelState.complete) {
        throw "Method 'complete()' should be called";
      }
    } else {
      _updateState(RequestModelState.loadingBlocked);
    }
    return Future.value(model);
  }

  /// Called after the task is completed for follow-up processing.
  @mustCallSuper
  RequestModel<T> onComplete(RequestModelCompletion<T>? completion) {
    _userCompletion = completion;
    return this;
  }

  /// Registers a callback to be called when the state changes.
  RequestModel<T> onStateChange(RequestModelStateChange<T> callback) {
    onStateChanged = callback;
    return this;
  }

  /// Called before the loading operation, typically changing the state to `RequestModelState.ready`.
  @protected
  willLoad() {}

  /// Completes all time-consuming tasks here;
  /// call `complete()` when the model is complete, and you may call it multiple times.
  /// Any exception and error thrown can be recorded to `outError`,
  /// `outError` is a List type.
  @protected
  Future loading();

  /// Called after the loading operation, typically changing the state to `RequestModelState.complete`.
  @protected
  didLoad() {}

  /// Determines if the request has permission to proceed.
  /// If it returns `false`, the loading() call will be blocked and the state will become `loadingBlocked`.
  /// Can be overridden using a mixin.
  @protected
  bool hasPermission() {
    return true;
  }

  /// Call this when the request is completed.
  @mustCallSuper
  @protected
  void complete() {
    _updateState(RequestModelState.complete);
    didLoad();
    _userCompletion?.call(model);
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
