import 'request_model.dart';

extension RequestModelOnList on List<RequestModel> {
  /// Executes the list of [RequestModel] instances sequentially.
  ///
  /// [onComplete] is an optional callback that is called when all requests have been processed.
  /// The callback receives three lists:
  /// - [successes]: Requests that completed successfully.
  /// - [failures]: Requests that failed with an error.
  /// - [blocked]: Requests that were blocked.
  ///
  /// If [haltOnError] is true, the execution will stop at the first failure.
  Future<void> executeSequentially({
    Function(
      List<RequestModel> successes,
      List<RequestModel> failures,
      List<RequestModel> blocked,
    )? onComplete,
    bool haltOnError = true,
  }) async {
    var successes = <RequestModel>[];
    var failures = <RequestModel>[];
    var blocked = <RequestModel>[];
    for (var requestModel in this) {
      RequestModel api = await requestModel.execute();
      if (api.hasError) {
        failures.add(api);
        if (haltOnError) {
          break;
        }
      } else if (api.state == RequestModelState.loadingBlocked) {
        blocked.add(api);
      } else {
        successes.add(api);
      }
    }
    onComplete?.call(successes, failures, blocked);
  }

  /// Executes the list of [RequestModel] instances concurrently.
  ///
  /// [onComplete] is an optional callback that is called when all requests have been processed.
  /// The callback receives three lists:
  /// - [successes]: Requests that completed successfully.
  /// - [failures]: Requests that failed with an error.
  /// - [blocked]: Requests that were blocked.
  Future<void> executeConcurrently({
    Function(
      List<RequestModel> successes,
      List<RequestModel> failures,
      List<RequestModel> blocked,
    )? onComplete,
  }) async {
    List<Future> executions = [];
    for (var element in this) {
      executions.add(element.execute());
    }
    await Future.wait(executions);
    var successes = <RequestModel>[];
    var failures = <RequestModel>[];
    var blocked = <RequestModel>[];
    for (var api in this) {
      if (api.hasError) {
        failures.add(api);
      } else if (api.state == RequestModelState.loadingBlocked) {
        blocked.add(api);
      } else {
        successes.add(api);
      }
    }
    onComplete?.call(successes, failures, blocked);
  }
}
