import 'package:flutter_api_model/flutter_api_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

mixin APIWithLoginNeed {
  bool hasPermission() {
    bool isLogin = something();
    return isLogin;
  }
}

class BaseAPI {
  Dio dio = Dio();

  BaseAPI() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': 'my_token'};
  }
}

class ProfileAPIModel extends BaseAPI
    with APIModel<ProfileAPIModel>, APIWithLoginNeed {
  ProfileAPIModel({required this.inUserId});

  String inUserId;

  User? outUser;

  @override
  load() async {
    try {
      final response = await dio.request('/user/profile');
      outUser = User.jsonToUser(response.data['user']);
    } catch (e) {
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
    final requestModel = ProfileAPIModel(inUserId: 'userId');

    // await
    await requestModel.start();
    if (!requestModel.hasError) {
      final user = requestModel.outUser;
    } else {
      final error = requestModel.outError;
    }
    // closure
    requestModel.onCompletion((model) {
      if (!requestModel.hasError) {
        final user = requestModel.outUser;
      } else {
        final error = requestModel.outError;
      }
    }).start();
  });
}
