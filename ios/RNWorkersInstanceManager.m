#import "RNWorkersInstanceManager.h"
#import <React/RCTLog.h>

@implementation RNWorkersInstanceManager
{
  RNWorkersInstanceData *_data;
  BOOL _valid;
}

RCT_EXPORT_MODULE(WorkersInstanceManager);

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"message"];
}

- (instancetype)initWithData:(RNWorkersInstanceData *)data
{
  if (self = [self init]) {
    _data = data;
    _valid = YES;
  }
  return self;
}

- (void)invalidate
{
  _valid = NO;
}

- (dispatch_queue_t)methodQueue
{
  return RCTGetMethodQueue();
}

static dispatch_queue_t RCTGetMethodQueue()
{
  static dispatch_queue_t queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("com.vonex.reactnative.worker", DISPATCH_QUEUE_SERIAL);
  });
  return queue;
}

RCT_EXPORT_METHOD(workerStarted)
{
  // The worker bridge may initialize and then quickly restart when debugging remotely.
  // To avoid losing messages, we acknowledge the worker start after a short delay.
  __weak __typeof__(self) weakSelf = self;
  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
  dispatch_after(delay, dispatch_get_main_queue(), ^{
    __typeof__(self) strongSelf = weakSelf;
    if (strongSelf) {
      BOOL valid = strongSelf->_valid;
      RNWorkersInstanceData *data = strongSelf->_data;
      if (valid && data.startedBlock) {
        data.startedBlock(nil);
        data.startedBlock = nil;
      }
    }
  });
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSString *)message)
{
  if (!_data.parentManager) {
    RCTLogWarn(
      @"You're invoking self.postMessage from the main JavaScript context, "
       "which is a no-op. To send a message to a specific Worker instance, "
       "invoke worker.postMessage on that instance."
    );
    return;
  }

  NSDictionary *body = @{@"key": _data.key, @"message": message};
  [_data.parentManager sendEventWithName:@"message" body:body];
}

@end
