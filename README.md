## Features
`Modeling of network requests,  which manages input parameters and output parameters, which follows the "In-Out" naming convention.`

### Naming rules:
- The prefix of the input parameter: in
    - (inUsername, inPassword)
- The prefix of the return value: out
    - (outLoginUser)

## Getting started


## Usage
```dart
doAsync() async {
    LoginAPI api = await LoginAPI(inNickname: 'jack', inPassword: '12345',).execute();
    if (api.hasError) {
      alert(api.outError);
    } else {
      User? currentUser = api.outUser;
      if(currentUser != null) {
        pagePush();
      } else {
        alert('User does not exist');
      }
    }
}
```

```dart
doSync() {
    LoginAPI(inNickname: 'jack', inPassword: '12345').onComplete((api) {
      if (api.hasError) {
        alert(api.outError);
      } else {
        User? currentUser = api.outUser;
        if (currentUser != null) {
          pagePush();
        } else {
          alert('User does not exist');
        }
      }
    }).execute();
}
```
### class define
```dart
class LoginAPI extends ModelAPI<LoginAPI> {
  LoginAPI({required this.inNickname, required this.inPassword});

  String inNickname;

  String inPassword;

  User? outUser;

  @override
  loading() async {
    try {
      outUser = await httpRequestUser();
    } catch (e) {
      outError = e;
    } finally {
      complete();
    }
  }
}
```

## Additional information

