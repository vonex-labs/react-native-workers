#import "RNWorker.h"
#import <React/RCTAssert.h>

@implementation RNWorker

RCT_EXPORT_MODULE();

- (void)invalidate {
  [self.bridge invalidate];
}

RCT_EXPORT_METHOD(postMessage:(id)message)
{
  RCTAssert(self.parent, @"Expected parent to be set");
  NSString *eventName = [NSString stringWithFormat:@"message:%i", self.key];
  [self.parent sendEventWithName:eventName body:message];
}

@end
