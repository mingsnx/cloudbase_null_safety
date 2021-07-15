#import "Aspects.h"
#import "WXApi.h"
#import <Flutter/Flutter.h>

@interface CloudbaseWxAuthDelegate : NSObject<WXApiDelegate> {
  FlutterResult _callback;
  
  id<AspectToken> _hookOpenUrl;
  id<AspectToken> _hookOpenUrlWithOptions;
  id<AspectToken> _hookHandleOpenUrl;
  id<AspectToken> _hookContinueUserActivity;
};

- (void)registerDelegate;
- (void)unregisterDelegate;
- (void)setCallback:(FlutterResult)callback;

@end
