import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterPluginMep {
  static final MethodChannel _channel =
      const MethodChannel('flutter_plugin_mep')
        ..setMethodCallHandler(mepCallbackHandler);
  static Map<String, Function?> callbackMap = {};

  /// Setup moxo domain, Notice: This API MUST be invoked first before 'link'
  /// [domain] is your server domain.
  static setupDomain(String domain) {
    _channel.invokeMethod('setupDomain', [domain]);
  }

  /// Link user with access token.
  /// [token] user access token.
  static Future<dynamic> linkUserWithAccessToken(String token) async {
    try {
      return await _channel.invokeMethod('linkUserWithAccessToken', [token]);
    } catch (e) {
      rethrow;
    }
  }

  /// Show mep main window.
  static void showMEPWindow() {
    _channel.invokeMethod('showMEPWindow');
  }

  /// Open chat with chat ID [chatId] and scroll to the specified feed [feedSequence] if present.
  /// [chatId] chat id.
  /// [feedSequence] feed id. If you need to jump to specific feed, pass feed id, else pass empty.
  static void openChat(String chatId, String feedSequence) {
    _channel.invokeMethod('openChat', [chatId, feedSequence]);
  }

  /// Start a meet with specific topic and members . Meeting screen will show up once meeting started succeed.
  /// [topic] Meet topic
  /// [uniqueIds] Invited members
  /// [chatId] Id of the chat where you want to place meeting related messages
  /// [options] Additional options when start a meeting, optional. Supported key-values list below:
  ///           {
  ///             "auto_join_audio": true,     //Boolean value, to join audio automaticaly or not, default is true.
  ///             "auto_start_video": true     //Boolean value, to start video automaticaly or not, default is false.
  ///           }
  static Future<dynamic> startMeet(String topic, List<String> uniqueIds,
      String chatId, Object options) async {
    try {
      return await _channel
          .invokeMethod('startMeet', [topic, uniqueIds, chatId, options]);
    } catch (e) {
      rethrow;
    }
  }

  /// Join a scheduled meeting as participant or start scheduled meeting as host.
  /// [sessionId] The meeting's session id, required.
  static Future<dynamic> joinMeet(String sessionId) async {
    try {
      return await _channel.invokeMethod('joinMeet', [sessionId]);
    } catch (e) {
      rethrow;
    }
  }

  /// Show meet ringer UI on event of an incoming call. For Android only.
  /// [sessionId] The meeting's session id, required.
  static Future<dynamic> showMeetRinger(String sessionId) async {
    try {
      return await _channel.invokeMethod('showMeetRinger', [sessionId]);
    } catch (e) {
      rethrow;
    }
  }

  /// Register your device token for push notification.
  /// [deviceToken] The device token
  static Future<dynamic> registerNotification(String deviceToken) async {
    _channel.invokeMethod('registerNotification', [deviceToken]);
  }

  /// Parse the notification to extract related info.
  /// [notificationPayload] The notification payload in json string format
  /// When parse success, we will return with object like below:
  ///  {
  ///      //For chat:
  ///      "chat_id": "CBPErkesrtOeFfURA6gusJAD"
  ///      "feed_sequence": 191
  ///
  ///      //For meet:
  ///      "session_id": "255576178"
  ///  }
  /// When parse failed, will throw exception.s
  static Future<dynamic> parseRemoteNotification(
      String notificationPayload) async {
    try {
      return await _channel
          .invokeMethod('parseRemoteNotification', [notificationPayload]);
    } catch (e) {
      rethrow;
    }
  }

  /// Unlink the account from the MEP service including the push notification service.
  static Future<dynamic> unlink() async {
    try {
      return await _channel.invokeMethod('unlink');
    } catch (e) {
      rethrow;
    }
  }

  /// Unlink the account from the MEP service locally, and device still can receive the push notifications.
  static Future<dynamic> localUnlink() async {
    try {
      return await _channel.invokeMethod('localUnlink');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> mepCallbackHandler(MethodCall call) async {
    Function? handler = callbackMap[call.method];
    if (handler != null) {
      // Function.apply(handler, call.arguments);
      handler(call.arguments as String);
    }
  }

  static onCallButtonClicked(Function? handler) {
    addCallbacks(handler, "onCallButtonClicked");
  }

  static addCallbacks(Function? callback, String? callbackKey) {
    if (callback != null && callbackKey != null) {
      callbackMap[callbackKey] = callback;
    } else if (callbackKey != null) {
      callbackMap.remove(callbackKey);
    }
  }
}
