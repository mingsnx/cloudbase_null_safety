#import "CloudbaseWxAuth.h"

@implementation CloudbaseWxAuth

static CloudbaseWxAuth *instance = nil;

+ (CloudbaseWxAuth*) initialize:(NSString *)wxAppid link:(NSString *)link callback:(FlutterResult)callback {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[CloudbaseWxAuth alloc] initWithAppid:wxAppid link:link callback:callback];
  });
    
  return instance;
}

+ (CloudbaseWxAuth*) getInstance {
    return instance;
}

- (CloudbaseWxAuth*) initWithAppid:(NSString *)wxAppid link:(NSString *)link callback:(FlutterResult)callback {
  self = [super init];
  
  if (self) {
    _wxAppid = wxAppid;
    _delegate = [[CloudbaseWxAuthDelegate alloc] init];
    
    // 注册app
    bool isRegisterApp = [WXApi registerApp:wxAppid universalLink: link];
    if (!isRegisterApp) {
      callback([FlutterError errorWithCode:@"WX_AUTH_REGISTER_FAILED" message:@"WX_AUTH_REGISTER_FAILED" details:nil]);
    }
    
    // 注册delegate
    [_delegate registerDelegate];
  }

  return self;
}

- (void) login:(FlutterResult)callback {
  if (![WXApi isWXAppInstalled]) {
    // 微信未安装
    callback([FlutterError errorWithCode:@"WX_AUTH_NO_INSTALLED" message:@"WX_AUTH_NO_INSTALLED" details:nil]);
    return;
  }
  
  [_delegate setCallback:callback];
  
  SendAuthReq *req = [[SendAuthReq alloc] init];
  req.scope = @"snsapi_userinfo";
  req.state = @"diandi_wx_login";
  [WXApi sendReq:req completion:nil];
}

@end
