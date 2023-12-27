![moxo](https://assets-global.website-files.com/612ecbcc615e87b0b9b38524/62037243f5ede375a8705a34_Moxo-Website-Button.svg)

[ [Introduce](#introduce) &bull; [Preparation](#preparation) &bull; [Installation](#installation) &bull; [Initialization](#initialization) &bull; [Sample Code](#sample-code) &bull; [API Doc](#api-doc)]

## Introduce

**flutter_plugin_mep** is a [moxo sdk](https://www.moxo.com/platform/sdks) flutter wrapper. Provide Moxo OneStop capabilities to your mobile app built on [Flutter](https://flutter.dev/)

### Supported Platforms

* iOS 13.0+
* Android 4.4+

## Preparation

Below sdk or tools are required before start to use flutter_plugin_mep.

* Flutter v3.7.10+
* Dart v2.19.6+

### Android

* Android Studio
* Android SDK v19+

### iOS

* Xcode v14.1+
* Cocoapod v1.11.0+

For more flutter set up details, please ref to [flutter official site](https://flutter.dev/docs/get-started/install)

## Installation

1. Add moxo flutter plugin to flutter project. Open pubspec.yml file in main project and add below in dependencies secion:

```
dependencies:
  ...
  flutter_plugin_mep:
      git:
        url: git@github.com:Moxtra/flutter_plugin_mep.git
      version: 8.11.2
      #You can change version to latest one.
```

2. Install added plugin:

* From the terminal, run:

```
  flutter pub get.
```

* From Android Studio/IntelliJ:

```
    Click Packages get in the action ribbon at the top of pubspec.yaml.
```

* From VS Code:

```
    Click Get Packages located in right side of the action ribbon at the top of pubspec.yaml.
```

3. iOS Specific Steps

* Add moxo cocoapod repo as source into Podfile under ``./ios/Podfile``:

```
source 'https://maven.moxtra.com/repo/moxtra-specs.git'
```

* Change pod deployment platform to iOS 13+

Sample:

```ruby
platform :ios, '13.0'
# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

source 'https://maven.moxtra.com/repo/moxtra-specs.git'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

# rest of the file...
```

## Initialization

### Login

Before login, we need to get access token, by Moxo RestAPI:

```dart
//Requre dependency 'http'
var domain = {your_domain};

final response = await http.post(Uri.https(domain, 'v1/core/oauth/token'),
    body: jsonEncode({
      'client_id': {client_id},
      'client_secret': {client_secret},
      'org_id': {org_id},
      'email': {email} 
      //'unique_id': {unique_id}
    }),
    headers: {'Content-Type': 'application/json'});
var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
var accessToken = decodedResponse['access_token'];
```

Import plugin before use, then initialize moxo sdk and login with access token:

```dart
import 'package:flutter_plugin_mep/flutter_plugin_mep.dart';
//...
//...
FlutterPluginMep.setupDomain(domain);
FlutterPluginMep.linkUserWithAccessToken(accessToken)
  .then((response) => {
        if (response != null &&
            response is String &&
            response == 'success')
          {
            //Login success.
            FlutterPluginMep.showMEPWindow()
          }
      })
  .catchError(handleError);
```

### Show MEP window

After login successful, we can show MEP window directly.

```dart
FlutterPluginMep.showMEPWindow()
```

or if you expecting just a timeline view instead of full mep window:
```dart
FlutterPluginMep.showMEPWindowLite()
```

## Sample Code

### Open existing chat

If user is logged in, call open chat API to open existing chat. If not logged in or chat does not exists, API will return error with error code and error message.

```dart
FlutterPluginMep.openChat('CBSmiUUjyIJP7gR8YIpiagvH', '')
```

### Start meet

If user is logged in, call start meet API to start an instant meet. If start successful, meet UI will show directly, otherwise, error will be returned with error code and error message.

```dart
var attendeesUniqueIds = ['john001','smith002','ella003'];
FlutterPluginMep.startMeet(
        "Your meeting topic",
        attendeesUniqueIds,
        'CBSmiUUjyIJP7gR8YIpiagvH',
        {
         'auto_join_audio': true,
         'auto_join_video': false
        })
    .catchError(handleError)
```

### Join meet

If user is logged in, call join meet API to join an instant meet. If join successful, meet UI will show directly, otherwise, error will be returned with error code and error message.

```dart
FlutterPluginMep.joinMeet('1234567').catchError(handleError)
```

### Notification

1. Register token, here we use [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) for example, for how to integrate firebase cloud messaging in Flutter, please refer [official doc](https://firebase.google.com/docs/cloud-messaging/flutter/client)

```dart
    //Get token via firebase messaging
    if (defaultTargetPlatform == TargetPlatform.iOS) {
        token = await FirebaseMessaging.instance.getAPNSToken();
    } else if(defaultTargetPlatform == TargetPlatform.android) {
        token = await FirebaseMessaging.instance.getToken();
    }

    //Register token to moxo
    var response = await FlutterPluginMep.registerNotification(
        token);
    if (response != null &&
        response is String &&
        response == 'success') {
    print("register token success");
    }
```

2. Parse Notification payload

```dart
  //For example, parse notificaion when after app launch
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print('Got a message whilst in the background!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      try {
        var response = await FlutterPluginMep.parseRemoteNotification(
            json.encode(message.data));
        print(response);
        //response is a map, includes 'chat_id' or 'meet_id', we could do more actions based on the parse result:
        var chatId = response['chat_id'];
        var feed_sequence = response['feed_sequence'];
        FlutterPluginMep.openChat(chatId as String, feed_sequence as String);
      } catch (e) {
        print(e);
      }
    }
  });
```

## API Doc

[API doc](https://htmlpreview.github.io/?https://github.com/Moxtra/flutter_plugin_mep/blob/main/doc/api/index.html)
