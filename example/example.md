## Features
`High-level modeling of network requests, which manages input parameters and output parameters, following the "In-Out" naming convention.APIModel doesn't handle network requests directly; instead, it excels at network layer abstraction.`

## Getting started
#### Installing
Add the following dependency to your pubspec.yaml file:
```yaml
dependencies:
  flutter_api_model: latest_version
```
#### Importing
Import the package into your Dart code:
```dart
import 'package:flutter_api_model/flutter_api_model.dart';
```

## Supports both await and callback formats for flexibility.
#### Using `await`
```dart
final model = await UserSearchAPIModel(inUserId: '2024').start();
if (model.hasError) {
  error = model.outError;
} else {
  user = model.outUser;
}
```
#### Using callback
```dart
UserSearchAPIModel(inUserId: '2024').onComplete((model) {
  if (!model.hasError) {
    user = model.outUser;
  } else {
    error = model.outError;
  }
}).start();

```

## Class definition
### Naming rules:
- The prefix of the input parameter: in
    - (inUsername, inPassword)
- The prefix of the return value: out
    - (outLoginUser)

### There are three ways to define APIModel:
#### 1. Using mixin:
Ideal for scenarios without special initialization requirements.
```dart
class SomeAPIModel with APIModel<SomeAPIModel>
```
#### 2. Using inheritance:
Suitable for defining a base network request class that extends `APIModel`.
```dart
class BaseRequestModel extends APIModel<SomeAPIModel>
```
#### 3. Using a combination of mixin and inheritance (recommended):
Best for custom network requests, data processing, and separation of concerns. 
For example, `BaseRequest` can handle Dio operations and data transformation, 
while `APIModel` provides request flow and encapsulation.
```dart
class SomeAPIModel extends BaseRequest with APIModel<SomeAPIModel>
```
### Example: Defining `UserSearchAPIModel`:
```dart
class UserSearchAPIModel extends BaseRequest<Map> 
      with  APIModel<UserSearchAPIModel>, 
            OutError<FlutterError>,
            LoginNeed {
  UserSearchAPIModel({required this.inUserId});
  /// Input parameter
  String inUserId;
  /// Output result
  User? outUser;

  @override
  load() async {
    try {
      final response = await dio.request('/user/profile', cancelToken: cancelToken);
      outUser = User.converFrom(jsonObject);
    } on FlutterError catch (e) {
        outError = e;
    } catch (e) {
      if (CancelToken.isCancel(e) == false) { 
        // Handler error
        throw e;
      }
    } finally {
      finalize();
    }
  }

  @override
  bool cancel() {
    super.cancel();
    cancelToken.cancel('Operation canceled by the user');
    return true;
  }
}

/// Defines a base type if initialization work is needed
/// Defining `BaseRequest` Class
class BaseRequest<DataType> {
  final dio = Dio();

  final cancelToken = CancelToken(); 

  DataType? data;

  int? code;

  String? msg;

  BaseRequest() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': 'some_token'};
  }

  void fillData(Dio.Response response) {
    data = getData(response);
    code = response.statusCode;
    msg  = getMsg(response);
  }
}

/// Defines a mixin to override the `hasPermission` method, blocking calls when the user is not logged in.
/// Defining `LoginNeed` Mixin.
mixin LoginNeed {
  bool hasPermission() {
    return isLogin();
  }

  didBlock() {
    print('API request was blocked.');
  }
}

```

## Using Versions Prior to Dart 3.0
- [Go to the repository to download the source code](https://github.com/Meterwhite/flutter_api_model)
- Manually import the `lib` folder and rename it to `flutter_api_model`
- Locate the file `api_model.dart`, and change `abstract mixin class APIModel<T>` to `abstract class APIModel<T>`