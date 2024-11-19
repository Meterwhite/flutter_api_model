## Features
`Modeling of network requests,  which manages input parameters and output parameters, which follows the "In-Out" naming convention.`

### Naming rules:
- The prefix of the input parameter: in
    - (inUsername, inPassword)
- The prefix of the return value: out
    - (outLoginUser)

## Getting started
#### Installing
```yaml
dependencies:
  flutter_api_model: latest_version
```
#### Importing
```dart
import 'package:flutter_api_model/flutter_api_model.dart';
```

### Using `await`
```dart
final model = await ProfileAPIModel(inUserId: '2024').start();
if (model.hasError) {
  final error = model.outError;
} else {
  final user = model.outUser;
}
```

### Using callback
```dart
ProfileAPIModel(inUserId: '2024').onComplete((model) {
  if (!model.hasError) {
    final user = model.outUser;
  } else {
    final error = model.outError;
  }
}).start();

```

### Class definition
```dart
class ProfileAPIModel extends BaseAPI<Map> with ModelAPI<ProfileAPIModel>, APIWithLoginNeed {
  ProfileAPIModel({required this.inUserId});

  /// Input parameter
  String inUserId;
  /// Output result
  User? outUser;

  @override
  load() async {
    try {
      final response = await dio.request('/user/profile');
      outUser = User.converFrom(jsonObject);
    } catch (e) {
      outError = e;
    } finally {
      finalize();
    }
  }
}

/// Defines a base type if initialization work is needed
class BaseAPI<T> {
  Dio dio = Dio();

  T? jsonObject;

  BaseAPI() {
    dio.options.baseUrl = 'https://base_url.com';
    dio.options.headers = {'token': '2024'};
  }

  void fillJson(String jsonString) {
    jsonObject = convert(jsonString);
  }
}

mixin APIWithLoginNeed {
  bool hasPermission() {
    return isLogin();
  }
}

```
