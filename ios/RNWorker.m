#import "RNWorker.h"
#import <React/RCTAssert.h>

@implementation RNWorker

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"message"];
}

- (void)invalidate {
  [self.bridge invalidate];
}

RCT_EXPORT_METHOD(postMessage:(id)message)
{
  RCTAssert(self.parent, @"Expected parent to be set");
  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"key"] = @(self.key);
  body[@"message"] = message;
  [self.parent sendEventWithName:@"message" body:body];
}

@end
