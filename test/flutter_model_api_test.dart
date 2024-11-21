import 'package:flutter_api_model/flutter_api_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

mixin APIWithLoginNeed {
  bool hasPermission() {
    bool isLogin = something();
    return isLogin;
  }
}

class BaseRequest {
  Dio dio = Dio();

  BaseRequest() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': 'my_token'};
  }
}

class ProfileAPIModel extends BaseRequest
    with APIModel<ProfileAPIModel>, OutError<FlutterError>, APIWithLoginNeed {
  ProfileAPIModel({required this.inUserId});

  String inUserId;

  User? outUser;

  @override
  load() async {
    try {
      final response = await dio.request('/user/profile');
      outUser = User.jsonToUser(response.data['user']);
    } on FlutterError catch (e) {
      outError = e;
    } finally {
      finalize();
    }
  }
}

something() {}

requestUser() {}

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
    profileAPIModel.onCompletion((model) {
      if (!profileAPIModel.hasError) {
        final user = profileAPIModel.outUser;
      } else {
        final error = profileAPIModel.outError;
      }
    }).start();
  });
}
