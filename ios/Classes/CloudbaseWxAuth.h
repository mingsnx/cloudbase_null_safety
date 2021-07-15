#import "WXApi.h"
#import <Flutter/Flutter.h>
#import "CloudbaseWxAuthDelegate.h"

@interface CloudbaseWxAuth : NSObject {
  NSString* _wxAppid;
  CloudbaseWxAuthDelegate* _delegate;
};

+ (CloudbaseWxAuth*) initialize:(NSString *)wxAppid link:(NSString *)link callback:(FlutterResult)callback;
+ (CloudbaseWxAuth*) getInstance;
- (void) login:(FlutterResult)callback;

@end
