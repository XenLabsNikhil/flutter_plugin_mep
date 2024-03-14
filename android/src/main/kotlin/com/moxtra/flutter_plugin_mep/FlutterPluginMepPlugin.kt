package com.moxtra.flutter_plugin_mep

import android.app.Application
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.moxtra.mepsdk.FeatureConfig
import com.moxtra.mepsdk.MEPClient
import com.moxtra.sdk.common.ApiCallback

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

import org.json.JSONArray
import com.moxtra.mepsdk.data.MEPStartMeetOptions
import ext.org.apache.commons.lang3.StringUtils
import org.json.JSONException


/** FlutterPluginMepPlugin */
class FlutterPluginMepPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mFlutterPluginMepPlugin: FlutterPlugin.FlutterPluginBinding
    private var TAG: String = "FlutterPluginMepPlugin"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_plugin_mep")
        channel.setMethodCallHandler(this)
        mFlutterPluginMepPlugin = flutterPluginBinding
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setupDomain" -> {
                setupDomain(call, result)
            }
            "linkUserWithAccessToken" -> {
                linkUserWithAccessToken(call, result)
            }
            "showMEPWindow" -> {
                showMEPWindow(call, result)
            }
            "openChat" -> {
                openChat(call, result)
            }
            "startMeet" -> {
                startMeet(call, result)
            }
            "joinMeet" -> {
                joinMeet(call, result)
            }
            "registerNotification" -> {
                registerNotification(call, result)
            }
            "parseRemoteNotification" -> {
                parseRemoteNotification(call, result)
            }
            "showMeetRinger" -> {
                showMeetRinger(call, result)
            }
            "unlink" -> {
                unlink(call, result, false)
            }
            "localUnlink" -> {
                unlink(call, result, true)
            }
            "showMEPWindowLite" -> {
                showMEPWindowLite(call, result)
            }
            "setFeatureConfig" -> {
                setFeatureConfig(call, result)
            }
            "isLinked" -> {
                isLinked(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun showMeetRinger(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var sessionId: String = parameters.get(0) as String
            MEPClient.showMeetRinger(sessionId, object : ApiCallback<Void> {
                override fun onCompleted(rlt: Void?) {
                    result.success("success")
                }

                override fun onError(errorCode: Int, errorMsg: String?) {
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun registerNotification(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var token: String = parameters.get(0) as String
            MEPClient.registerNotification(token, null, null, null, object : ApiCallback<Void> {
                override fun onCompleted(rlt: Void?) {
                    result.success("success")
                }

                override fun onError(errorCode: Int, errorMsg: String?) {
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun parseRemoteNotification(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var payload: String = parameters.get(0) as String
            try {
                var jsonObject: JSONObject = JSONObject(payload)
                if (MEPClient.isMEPNotification(json2Intent(jsonObject))) {
                    MEPClient.parseRemoteNotification(
                        json2Intent(jsonObject),
                        object : ApiCallback<Map<String, String>> {
                            override fun onCompleted(rlt: Map<String, String>) {
                                var jsonObject = JSONObject()
                                var keys = rlt.keys
                                for (key in keys) {
                                    when (key) {
                                        "chat_id", "feed_sequence", "session_id" -> jsonObject.put(
                                            key,
                                            rlt.getValue(key)
                                        )
                                        "meet_id" -> {
                                            var meetId = rlt.getValue(key)
                                            jsonObject.put("session_id", meetId)
                                        }
                                    }
                                }
                                result.success(jsonObject.toString())
                            }

                            override fun onError(errorCode: Int, errorMsg: String?) {
                                result.error("" + errorCode, errorMsg, "")
                            }
                        })
                } else {
                    result.error("-1", "Not moxo payload", "")
                }
            } catch (e: JSONException) {
                result.error("-1", "invalid parameter: Not fcm payload", "")
            }
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun setupDomain(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var domain: String = parameters.get(0) as String
            MEPClient.initialize(mFlutterPluginMepPlugin.applicationContext as Application?)
            MEPClient.setupDomain(domain, null)
            result.success("success")
        } else {
            result.error("-1", "invalid parameter", "")
        }

    }

    private fun linkUserWithAccessToken(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var accessToken: String = parameters.get(0) as String
            MEPClient.linkWithAccessToken(accessToken, object : ApiCallback<Void?> {
                override fun onCompleted(rlt: Void?) {
                    Log.d(
                        TAG,
                        "initWithAccessToken successful..."
                    )
                    result.success("success")
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.d(
                        TAG,
                        "initWithAccessToken failed, errCode:$errorCode, errMsg:$errorMsg"
                    )
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun showMEPWindow(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "showMEPWindow called...")
        if (MEPClient.isLinked()) {
            Log.d(TAG, "MEP is linked and showMEPWindow...")
            MEPClient.showMEPWindow(mFlutterPluginMepPlugin.applicationContext)
        }
    }


    private fun showMEPWindowLite(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "showMEPWindowLite called...")
        if (MEPClient.isLinked()) {
            Log.d(TAG, "MEP is linked and showMEPWindowLite...")
            MEPClient.showMEPWindowLite(mFlutterPluginMepPlugin.applicationContext)
        }
    }

    private fun openChat(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "openChat called...")
        if (!MEPClient.isLinked()) {
            result?.error("-1", "Not Linked", "")
            return
        }
        var parameters = call.arguments
        if (parameters != null && parameters is List<*>) {
            val paraLength = parameters.size
            var chatId: String = ""
            var chatFeedSequence: Long = 0L
            if (paraLength > 1) {
                val chatFeedSequenceStr = parameters.get(1) as String
                chatFeedSequence =
                    if (chatFeedSequenceStr.isNullOrEmpty()) 0 else chatFeedSequenceStr.toLong()
            }

            if (paraLength > 0) {
                chatId = parameters.get(0) as String
            }

            MEPClient.openChat(chatId, chatFeedSequence, object : ApiCallback<Void?> {
                override fun onCompleted(rult: Void?) {
                    Log.d(TAG, "openChat successful...")
                    result.success("")
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.d(TAG, "openChat failed, errCode:$errorCode, errMsg:$errorMsg")
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun startMeet(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments
        var topic: String? = null
        var uniqueIds: List<String>? = null
        var chatId: String? = null
        var autoJoinAudio = true
        var autoStartVideo = false
        var options: Map<String, Boolean>? = null

        Log.d(TAG, "startMeet called...")
        if (!MEPClient.isLinked()) {
            result.error("-1", "Not Linked", "")
            return
        }
        if (parameters != null && parameters is List<*>) {
            val paraLength = parameters.size
            if (paraLength > 3) {
                options = parameters.get(3) as Map<String, Boolean>
                autoJoinAudio = options.get("auto_join_audio") == true
                autoStartVideo = options.get("auto_start_video") == true
            }

            if (paraLength > 2) {
                chatId = parameters.get(2) as String?
            }

            if (paraLength > 1) {
                uniqueIds = parameters.get(1) as ArrayList<String>?
            }

            if (paraLength > 0) {
                topic = parameters.get(0) as String?
            }

            if (StringUtils.isEmpty(topic) || StringUtils.equals(topic, "null")) {
                result.error("-1", "Topic is empty!", "")
                return;
            }

            Log.d(
                TAG,
                "startMeet, parameters are: topic->" + topic + ", uniqueIds->" + uniqueIds + ", chatId->" + chatId + ", autoJoinAudio->" + autoJoinAudio + ", autoStartVideo->" + autoStartVideo
            )
            val startMeetOptions = MEPStartMeetOptions()
            startMeetOptions.topic = topic!!
            if (!StringUtils.isEmpty(chatId) && !StringUtils.equals(chatId, "null")) {
                startMeetOptions.chatID = chatId
            }
            if (uniqueIds != null) {
                startMeetOptions.uniqueIDs = uniqueIds
            }
            if (options != null) {
                startMeetOptions.setAutoJoinAudio(autoJoinAudio)
                startMeetOptions.setAutoStartVideo(autoStartVideo)
            }

            MEPClient.startMeet(startMeetOptions, object : ApiCallback<String?> {
                override fun onCompleted(sessionId: String?) {
                    val jsonObject = JSONObject()
                    jsonObject.put("session_id", sessionId)
                    result.success(jsonObject.toString())
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun joinMeet(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "joinMeet called...")
        if (!MEPClient.isLinked()) {
            result?.error("-1", "Not Linked", "")
            return
        }
        var parameters = call.arguments;
        if (parameters != null && parameters is List<*>) {
            var sessionId = parameters.get(0) as String
            Log.d(TAG, "joinMeet, parameter is: sessionId->" + sessionId)
            MEPClient.joinMeet(sessionId, object : ApiCallback<Void?> {
                override fun onCompleted(rlt: Void?) {
                    Log.d(
                        TAG,
                        "joinMeet successful..."
                    )
                    result.success("success")
                }

                override fun onError(errorCode: Int, errorMsg: String) {
                    Log.d(
                        TAG,
                        "joinMeet failed, errCode:$errorCode, errMsg:$errorMsg"
                    )
                    result.error("" + errorCode, errorMsg, "")
                }
            })
        } else {
            result.error("-1", "invalid parameter", "")
        }
    }

    private fun unlink(
        @NonNull call: MethodCall,
        @NonNull result: Result,
        @NonNull isLocalUnlink: Boolean
    ) {
        var callback = object : ApiCallback<Void?> {
            override fun onCompleted(rlt: Void?) {
                Log.d(
                    TAG,
                    "unlink successful..."
                )
                result.success("success")
            }

            override fun onError(errorCode: Int, errorMsg: String) {
                Log.w(
                    TAG,
                    "unlink failed, errCode:$errorCode, errMsg:$errorMsg"
                )
                result.error("" + errorCode, errorMsg, "")
            }
        }
        if (isLocalUnlink) {
            Log.d(TAG, "localUnlink called ...")
            MEPClient.localUnlink(callback)
        } else {
            Log.d(TAG, "unlink called ...")
            MEPClient.unlink(callback)
        }
    }

    // Feature-key-value
    // Hide Inactive Relation Chat       hide_inactive_relation_chat        true/false in type Boolean
    private fun setFeatureConfig(@NonNull call: MethodCall, @NonNull result: Result) {
        var parameters = call.arguments
        if (parameters != null && parameters is List<*> && parameters.size > 0) {
            var featureConfigs = parameters[0] as Map<String, Object>
            var keyset = featureConfigs?.keys
            if (keyset != null) {
                for (key in keyset) {
                    when (key) {
                        "hide_inactive_relation_chat" -> {
                            (featureConfigs[key] as? Boolean)?.let {
                                FeatureConfig.hideInactiveRelationChat(
                                    it
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private fun isLinked(@NonNull call: MethodCall, @NonNull result: Result) {
        val isLinked: Boolean = MEPClient.isLinked()
        result.success(isLinked)
    }

    private fun json2Intent(jsonObject: JSONObject?): Intent {
        val intent = Intent()
        val keys = jsonObject?.keys();
        while (keys?.hasNext() == true) {
            val key = keys.next()
            intent.putExtra(key, jsonObject?.getString(key))
        }
        return intent
    }
}
