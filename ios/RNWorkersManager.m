//XXX support CodePush

#import "RNWorkersManager.h"
#import "RNWorkersInstanceManager.h"
#import "RNWorkersDevSettings.h"
#import <React/RCTAssert.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLog.h>

@implementation RNWorkersManager
{
  NSMutableDictionary *_workers;
  NSMutableSet *_ports;
}

RCT_EXPORT_MODULE(WorkersManager);

- (instancetype)init
{
  if (self = [super init]) {
    _workers = [NSMutableDictionary dictionary];
    _ports = [NSMutableSet set];
  }
  return self;
}

- (void)invalidate {
  for (NSNumber *key in _workers) {
    RNWorkersInstanceManager *worker = _workers[key];
    [worker stop];
  }
  [_workers removeAllObjects];
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

  __block NSString *bundleRoot = root;
  __block BOOL uniquePort = NO;

  if (port > 0) {
    if ([_ports containsObject:port]) {
      RCTLogError(@"Bundler port %@ is already in use by another worker.", port);
    } else {
      NSURLComponents *components = [NSURLComponents componentsWithURL:workerURL resolvingAgainstBaseURL:NO];
      if (components.port.unsignedIntegerValue == kRCTBundleURLProviderDefaultPort) {
        [_ports addObject:port];
        components.port = port;
        uniquePort = YES;
      }
      workerURL = components.URL;
    }
  }

  RCTBridge *workerBridge = [[RCTBridge alloc] initWithBundleURL:workerURL moduleProvider:^NSArray<id<RCTBridgeModule>> *{
    return @[[[RNWorkersDevSettings alloc] initWithBundleRoot:bundleRoot uniquePort:uniquePort]];
  } launchOptions:nil];

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
