#import "CloudbaseWxAuthDelegate.h"

@implementation CloudbaseWxAuthDelegate

- (void)registerDelegate {
  // 获取appDelegate
  FlutterAppDelegate* appDelegate = (FlutterAppDelegate*)[[UIApplication sharedApplication] delegate];
  
  // 注册wxApiDelegate
  _hookOpenUrl = [appDelegate aspect_hookSelector:@selector(application:openURL:sourceApplication:annotation:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, UIApplication* application, NSURL* url){
    return [WXApi handleOpenURL:url delegate:self];
  } error:NULL];
  
  _hookOpenUrlWithOptions = [appDelegate aspect_hookSelector:@selector(application:openURL:options:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, UIApplication* application, NSURL* url) {
    return [WXApi handleOpenURL:url delegate:self];
  } error:NULL];
  
  _hookHandleOpenUrl = [appDelegate aspect_hookSelector:@selector(application:handleOpenURL:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, UIApplication* application, NSURL* url){
    return [WXApi handleOpenURL:url delegate:self];
  } error:NULL];
  
  _hookContinueUserActivity = [appDelegate aspect_hookSelector:@selector(application:continueUserActivity:restorationHandler:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, UIApplication* application, NSUserActivity* userActivity){
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
  } error:NULL];
}

- (void)unregisterDelegate {
  // 注销delegate
  if (_hookOpenUrl != nil) {
    [_hookOpenUrl remove];
    _hookOpenUrl = nil;
  }
  if (_hookOpenUrlWithOptions != nil) {
    [_hookOpenUrlWithOptions remove];
    _hookOpenUrlWithOptions = nil;
  }
  if (_hookHandleOpenUrl != nil) {
    [_hookHandleOpenUrl remove];
    _hookHandleOpenUrl = nil;
  }
  if (_hookContinueUserActivity != nil) {
    [_hookContinueUserActivity remove];
    _hookContinueUserActivity = nil;
  }
}

- (void)setCallback:(FlutterResult)callback {
  _callback = callback;
}

- (void)onResp:(BaseResp *)resp {
  if (_callback == nil) {
    return;
  }
  
  if (resp.errCode == WXSuccess) {
    NSString* code = ((SendAuthResp *)resp).code;
    _callback(code);
  } else {
    _callback([FlutterError errorWithCode:@"WX_AUTH_LOGIN_FAILED" message:@"WX_AUTH_LOGIN_FAILED" details:nil]);
  }
  
  _callback = nil;
}

@end
