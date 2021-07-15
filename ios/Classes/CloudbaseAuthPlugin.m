#import "CloudbaseAuthPlugin.h"
#import "CloudbaseWxAuth.h"

@implementation CloudbaseAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"cloudbase_null_safety"
            binaryMessenger:[registrar messenger]];
  CloudbaseAuthPlugin* instance = [[CloudbaseAuthPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"wxauth.register" isEqualToString:call.method]) {
    [self handleWxAuthRegister:call callback:result];
  } else if ([@"wxauth.login" isEqualToString:call.method]) {
    [self handleWxAuthLogin:call callback:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleWxAuthRegister:(FlutterMethodCall*)call callback:(FlutterResult)callback {
  NSDictionary* arguments = (NSDictionary*)call.arguments;
  [CloudbaseWxAuth initialize:arguments[@"wxAppId"] link:arguments[@"wxUniLink"] callback:callback];
  callback(nil);
}

- (void)handleWxAuthLogin:(FlutterMethodCall*)call callback:(FlutterResult)callback {
  CloudbaseWxAuth *instance = [CloudbaseWxAuth getInstance];
  if (instance == nil) {
    callback([FlutterError errorWithCode:@"WX_AUTH_NO_INSTANCE" message:@"WX_AUTH_NO_INSTANCE" details:nil]);
    return;
  }
  
  [instance login:callback];
}

@end
