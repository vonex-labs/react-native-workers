#import "RNWorkersInstanceManager.h"
#import <React/RCTLog.h>

@implementation RNWorkersInstanceManager

RCT_EXPORT_MODULE(WorkersInstanceManager);

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"message"];
}

- (void)invalidate {
  [_strongBridge invalidate];
  _strongBridge = nil;
  _startedBlock = nil;
}

RCT_EXPORT_METHOD(workerStarted)
{
  if (_startedBlock) {
    _startedBlock(nil);
    _startedBlock = nil;
  }
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSString *)message)
{
  if (!_parentManager) {
    RCTLogWarn(
      @"You're invoking self.postMessage from the main JavaScript context, "
       "which is a no-op. To send a message to a specific Worker instance, "
       "invoke worker.postMessage on that instance."
    );
    return;
  }

  NSDictionary *body = @{@"key": _key, @"message": message};
  [_parentManager sendEventWithName:@"message" body:body];
}

@end
