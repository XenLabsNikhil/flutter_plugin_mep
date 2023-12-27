#import "FlutterPluginMep.h"
#import <MEPSDK/MEPSDK.h>
const static NSString * MEPFunctionBadRequestCode = @"999";
const static NSString *autoJoinAudioKey = @"auto_join_audio";
const static NSString *autoStartVideoKey = @"auto_start_video";

@interface FlutterPluginMep()<MEPClientDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end
@implementation FlutterPluginMep
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_plugin_mep"
            binaryMessenger:[registrar messenger]];
  FlutterPluginMep* instance = [[FlutterPluginMep alloc] init];
  [MEPClient sharedInstance].delegate = instance;
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"setupDomain" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
          NSArray *arguments = (NSArray *)call.arguments;
          NSString *domain = arguments[0];
          [[MEPClient sharedInstance] setupWithDomain:domain linkConfig:nil];
          result(nil);
      } else {
          result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
      }
  } else if ([@"linkUserWithAccessToken" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
          NSArray *arguments = (NSArray *)call.arguments;
          NSString *token = arguments[0];
          [[MEPClient sharedInstance] linkUserWithAccessToken:token completionHandler:^(NSError * _Nullable errorOrNil) {
              if (errorOrNil) {
                  result([self errorFromNSError:errorOrNil]);
              } else {
                  result(@"success");
              }
          }];
      } else {
          result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
      }
  } else if ([@"showMEPWindow" isEqualToString:call.method]) {
    [[MEPClient sharedInstance] showMEPWindow];
    result(nil);
  } else if ([@"showMEPWindowLite" isEqualToString:call.method]) {
    [[MEPClient sharedInstance] showMEPWindowLite];
    result(nil);
  } else if ([@"setFeatureConfig" isEqualToString:call.method]) {
    [self setFeatureConfig:call result:result];
  } else if ([@"openChat" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
          NSArray *arguments = (NSArray *)call.arguments;
          NSString *chatId = arguments[0];
          NSString *feedSequence = arguments[1];
          NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
          f.numberStyle = NSNumberFormatterDecimalStyle;
          NSNumber *theSequenceNumber = [f numberFromString:feedSequence];
          [[MEPClient sharedInstance] openChat:chatId withFeedSequence:theSequenceNumber completionHandler:^(NSError * _Nullable error) {
              if (error) {
                  result([self errorFromNSError:error]);
              } else {
                  result(@"success");
              }
          }];
      } else {
          result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
      }
  } else if ([@"startMeet" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
          NSString *topic = [call.arguments objectAtIndex:0];
          NSArray *unique_ids = [call.arguments objectAtIndex:1];
          NSString *chat_id = [call.arguments objectAtIndex:2];
          NSDictionary *options_dic = [call.arguments objectAtIndex:3];
          MEPStartMeetOptions *options = [[MEPStartMeetOptions alloc] init];
          options.chatID = chat_id;
          options.topic = topic;
          options.uniqueIDs = unique_ids;
          if (options_dic && ![options_dic isEqual:[NSNull null]]) {
              options.autoJoinAudio = [[options_dic objectForKey:autoJoinAudioKey] boolValue];
              options.autoStartVideo = [[options_dic objectForKey:autoStartVideoKey] boolValue];
          } else {
              options.autoJoinAudio = YES;
              options.autoStartVideo = NO;
          }
          if (![MEPClient sharedInstance].isLinked) {
              result([FlutterError errorWithCode:@"3" message:@"not linked yet" details:nil]);
              return;
          }
          [[MEPClient sharedInstance] startMeetWithOption:options completionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nonnull meetIDOrNil) {
              if (errorOrNil) {
                  result([self errorFromNSError:errorOrNil]);
              } else {
                  result(@"success");
              }
          }];
      }
  } else if ([@"joinMeet" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
        NSString *session_id = [call.arguments objectAtIndex:0];
        if (![MEPClient sharedInstance].isLinked) {
            result([FlutterError errorWithCode:@"3" message:@"not linked yet" details:nil]);
            return;
        }
        [[MEPClient sharedInstance] joinMeetWithMeetID:session_id completionHandler:^(NSError * _Nullable errorOrNil) {
            if (errorOrNil) {
                result([self errorFromNSError:errorOrNil]);
            } else {
                result(@"success");
            }
        }];
    } else {
        result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
    }
  } else if ([@"registerNotification" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
        NSString *deviceToken = [call.arguments objectAtIndex:0];
        if ([deviceToken isEqual:[NSNull null]])
            deviceToken = @"";
    
        NSData *tokenData = [self dataFromHexString:deviceToken];
          [[MEPClient sharedInstance] registerNotificationWithDeviceToken:tokenData completionHandler:^(NSError * _Nullable error) {
              if (error) {
                  result([self errorFromNSError:error]);
              } else {
                  result(@"success");
              }
          }];
    } else {
        result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
    }
  } else if ([@"parseRemoteNotification" isEqualToString:call.method]) {
      if ([call.arguments isKindOfClass:[NSArray class]]) {
          NSString *payload = [call.arguments objectAtIndex:0];
          if ([payload isEqual:[NSNull null]]) {
              result([FlutterError errorWithCode:MEPFunctionBadRequestCode message:@"parameter not found" details:nil]);
          }
          NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
          NSError *error;
          NSDictionary *payloadDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
          if (error) {
              result([self errorFromNSError:error]);
          } else {
              [[MEPClient sharedInstance] parseRemoteNotification:payloadDic completionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable info) {
                  if (error) {
                      result([self errorFromNSError:error]);
                  } else {
                      result(info);
                  }
              }];
          }
      }
  } else if ([@"localUnlink" isEqualToString:call.method]) {
      [[MEPClient sharedInstance] localUnlink];
      result(nil);
  } else if ([@"unlink" isEqualToString:call.method]) {
      [[MEPClient sharedInstance] unlink];
      result(nil);
  } else {
        result(FlutterMethodNotImplemented);
  }
}

- (FlutterError *)errorFromNSError:(NSError *)error {
    if (error) {
        return [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld",(long)error.code] message:error.localizedDescription details:error.userInfo];
    }
    return nil;
}

#pragma mark - MEPClientDelegate
#pragma mark -
- (void)setFeatureConfig:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.arguments isKindOfClass:[NSArray class]]) {
        NSArray *configsArr = (NSArray *)call.arguments;
        if (configsArr.count > 0) {
            NSDictionary *configs = configsArr.firstObject;
            if ([configs objectForKey:@"hide_inactive_relation_chat"]) {
                [MEPFeatureConfig sharedInstance].hidesInactiveRelationChats = [[configs objectForKey:@"hide_inactive_relation_chat"] boolValue];
            }
        }
    }
    result(nil);
}
#pragma mark - Helper
- (NSData *)dataFromHexString:(NSString *)string
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [string length] / 2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    return stringData;
}

@end
