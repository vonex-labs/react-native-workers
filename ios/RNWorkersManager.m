//XXX support CodePush
//XXX prevent double dev menu
//XXX support or disable remote debugging

#import "RNWorkersManager.h"
#import "RNWorkersInstanceManager.h"
#import <React/RCTAssert.h>
#import <React/RCTBundleURLProvider.h>

@implementation RNWorkersManager
{
  NSMutableDictionary *_workers;
}

RCT_EXPORT_MODULE(WorkersManager);

- (instancetype)init
{
  if (self = [super init]) {
    _workers = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)invalidate {
  for (NSNumber *key in _workers) {
    RNWorkersInstanceManager *worker = _workers[key];
    [worker stop];
  }

  [_workers removeAllObjects];
  _workers = nil;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"message"];
}

RCT_EXPORT_METHOD(startWorker:(nonnull NSNumber *)key
                   bundleRoot:(NSString *)root
               bundleResource:(NSString *)resource
                  bundlerPort:(nonnull NSNumber *)port
                     resolver:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject)
{
  RCTAssert(!_workers[key], @"Key already in use");
  NSURL *workerURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:root fallbackResource:resource];

  if (port > 0) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:workerURL resolvingAgainstBaseURL:NO];
    if (components.port.unsignedIntegerValue == kRCTBundleURLProviderDefaultPort) {
      components.port = port;
    }
    workerURL = components.URL;
  }

  RCTBridge *workerBridge = [[RCTBridge alloc] initWithBundleURL:workerURL moduleProvider:nil launchOptions:nil];
  RNWorkersInstanceManager *worker = [workerBridge moduleForName:@"WorkersInstanceManager"];

  worker.key = key;
  worker.startedBlock = resolve;
  worker.parentManager = self;
  worker.strongBridge = workerBridge;

  [_workers setObject:worker forKey:key];
}

RCT_EXPORT_METHOD(stopWorker:(nonnull NSNumber *)key)
{
  RNWorkersInstanceManager *worker = _workers[key];
  RCTAssert(worker, @"Expected worker for key");
  [worker stop];
  [_workers removeObjectForKey:key];
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)key
                      message:(nonnull NSString *)message)
{
  RNWorkersInstanceManager *worker = _workers[key];
  RCTAssert(worker, @"Expected worker for key");
  NSDictionary *body = @{@"key": key, @"message": message};
  [worker sendEventWithName:@"message" body:body];
}

@end
