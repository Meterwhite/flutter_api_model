import 'package:flutter_api_model/flutter_api_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';

mixin APIWithLoginNeed<T> on APIModel<T> {
  @override
  bool hasPermission() {
    bool isLogin = something();
    return isLogin;
  }
}

@optionalTypeArgs
mixin CancelEnable<T> on APIModel<T>, BaseRequest {

  @override
  bool isCancellable() {
    return true;
  }

  @override
  void cancel() {
    super.cancel();
    cancelToken.cancel();
  }
}

class BaseRequest {
  final dio = Dio();

  final cancelToken = CancelToken();

  BaseRequest() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': 'my_token'};
  }
}

class ProfileAPIModel extends BaseRequest
    with
        APIModel<ProfileAPIModel>,
        OutError<ProfileAPIModel, SomeError>,
        APIWithLoginNeed,
        CancelEnable {
  ProfileAPIModel({required this.inUserId});

  String inUserId;

  User? outUser;

  @override
  load() async {
    try {
      final response = await dio.request('/user/profile');
      outUser = User.jsonToUser(response.data['user']);
    } on SomeError catch (e) {
      outError = e;
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) {
        // ...
      }
    } finally {
      finalize();
    }
  }

}

something() {}

requestUser() {}

class SomeError {
  // ...
}

class User {
  static jsonToUser(String? json) {
    return something();
  }
}

void main() {
  test('adds one to input values', () async {
    final profileAPIModel = ProfileAPIModel(inUserId: 'userId');
    // await
    await profileAPIModel.start();
    if (!profileAPIModel.hasError) {
      final user = profileAPIModel.outUser;
    } else {
      final error = profileAPIModel.outError;
    }
    // closure
    profileAPIModel.onComplete((model) {
      if (!profileAPIModel.hasError) {
        final user = profileAPIModel.outUser;
      } else {
        final error = profileAPIModel.outError;
      }
    }).start();
  });
}
