import 'api_model.dart';

extension APIModelOnList on List<APIModel> {
  /// Executes the list of [APIModel] instances sequentially.
  ///
  /// [onComplete] is an optional callback that is called when all requests have been processed.
  /// The callback receives three lists:
  /// - [successes]: Requests that finalized successfully.
  /// - [failures]: Requests that failed with an error.
  /// - [blocked]: Requests that were blocked.
  ///
  /// If [haltOnError] is true, the execution will stop at the first failure.
  Future<void> executeSequentially({
    Function(
      List<APIModel> successes,
      List<APIModel> failures,
      List<APIModel> blocked,
    )? onComplete,
    bool haltOnError = true,
  }) async {
    var successes = <APIModel>[];
    var failures = <APIModel>[];
    var blocked = <APIModel>[];
    for (var requestModel in this) {
      APIModel api = await requestModel.start();
      if (api.hasError) {
        failures.add(api);
        if (haltOnError) {
          break;
        }
      } else if (api.state == APIModelState.blocked) {
        blocked.add(api);
      } else {
        successes.add(api);
      }
    }
    onComplete?.call(successes, failures, blocked);
  }

  /// Executes the list of [APIModel] instances concurrently.
  ///
  /// [onComplete] is an optional callback that is called when all requests have been processed.
  /// The callback receives three lists:
  /// - [successes]: Requests that finalized successfully.
  /// - [failures]: Requests that failed with an error.
  /// - [blocked]: Requests that were blocked.
  Future<void> executeConcurrently({
    Function(
      List<APIModel> successes,
      List<APIModel> failures,
      List<APIModel> blocked,
    )? onComplete,
  }) async {
    List<Future> executions = [];
    for (var element in this) {
      executions.add(element.start());
    }
    await Future.wait(executions);
    var successes = <APIModel>[];
    var failures = <APIModel>[];
    var blocked = <APIModel>[];
    for (var api in this) {
      if (api.hasError) {
        failures.add(api);
      } else if (api.state == APIModelState.blocked) {
        blocked.add(api);
      } else {
        successes.add(api);
      }
    }
    onComplete?.call(successes, failures, blocked);
  }
}
