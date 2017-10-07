#import "RNWorker.h"
#import "RNWorkerManager.h"
#import <React/RCTAssert.h>
#import <React/RCTBundleURLProvider.h>

@implementation RNWorkerManager
{
  NSMutableDictionary *_workers;
}

RCT_EXPORT_MODULE();

- (instancetype)init
{
  if (self = [super init]) {
    _workers = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)invalidate {
  for (NSNumber *key in _workers) {
    RNWorker *worker = _workers[key];
    [worker invalidate];
  }

  [_workers removeAllObjects];
  _workers = nil;
}

RCT_REMAP_METHOD(startWorker,
                 key:(nonnull NSNumber *)key
                 root:(NSString *)root
                 fallback:(NSString *)fallback
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  RCTAssert(!_workers[key], @"key already in use");
  NSURL *workerURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:root fallbackResource:fallback];
  RCTBridge *workerBridge = [[RCTBridge alloc] initWithBundleURL:workerURL moduleProvider:nil launchOptions:nil];

  RNWorker *worker = [workerBridge moduleForName:@"RNWorker"];
  worker.parent = self;
  worker.key = key;

  [_workers setObject:worker forKey:key];
  resolve(nil);
}

RCT_EXPORT_METHOD(stopWorker:(nonnull NSNumber *)key)
{
  RNWorker *worker = _workers[key];
  RCTAssert(worker, @"Expected worker for key");
  [worker invalidate];
  [_workers removeObjectForKey:key];
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)key
                      message:(id)message)
{
  RNWorker *worker = _workers[key];
  RCTAssert(worker, @"Expected worker for key");
  [worker sendEventWithName:@"message" body:message];
}

@end
