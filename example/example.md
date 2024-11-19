## Features
`Modeling of network requests,  which manages input parameters and output parameters, which follows the "In-Out" naming convention.`

### Naming rules:
- The prefix of the input parameter: in
    - (inUsername, inPassword)
- The prefix of the return value: out
    - (outLoginUser)

## Getting started


## Usage
### await形式
```dart
final requestModel = await ProfileRequestModel(inUserId: '2024').execute();
if (requestModel.hasError) {
    final error = requestModel.outError;
} else {
    final user = requestModel.outUser;
}
```
### 回调形式
```dart
ProfileRequestModel(inUserId: '2024').onComplete((model) {
    if (!requestModel.hasError) {
    final user = requestModel.outUser;
    } else {
    final error = requestModel.outError;
    }
}).execute();
```
### Class define
```dart
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

class BaseRequest {
  Dio dio = Dio();

  BaseRequest() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': '2024'};
  }
}

mixin RquestModelWithLoginNeed {
  bool hasPermission() {
    return isLogin();
  }
}
```

## Additional information

