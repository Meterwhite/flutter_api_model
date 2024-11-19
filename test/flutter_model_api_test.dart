import 'package:flutter_request_model/src/request_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

something() {}

requestUser() {}

mixin RquestModelWithLoginNeed {
  bool hasPermission() {
    bool isLogin = something();
    return isLogin;
  }
}

class User {
  static jsonToUser(String? json) {
    return something();
  }
}

class BaseRequest {
  Dio dio = Dio();

  BaseRequest() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': 'my_token'};
  }
}

class ProfileRequestModel extends BaseRequest
    with RequestModel<ProfileRequestModel>, RquestModelWithLoginNeed {
  ProfileRequestModel({required this.inUserId});

  String inUserId;

  User? outUser;

  @override
  loading() async {
    try {
      final response = await dio.request('/user/profile');
      outUser = User.jsonToUser(response.data['user']);
    } catch (e) {
      outError = e;
    } finally {
      complete();
    }
  }
}

void main() {
  test('adds one to input values', () async {
    final requestModel = ProfileRequestModel(inUserId: 'userId');

    // await
    await requestModel.execute();
    if (!requestModel.hasError) {
      final user = requestModel.outUser;
    } else {
      final error = requestModel.outError;
    }
    // closure
    requestModel.onComplete((model) {
      if (!requestModel.hasError) {
        final user = requestModel.outUser;
      } else {
        final error = requestModel.outError;
      }
    }).execute();
  });
}
