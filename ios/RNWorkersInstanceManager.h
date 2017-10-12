#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNWorkersInstanceManager : RCTEventEmitter <RCTBridgeModule>
- (void)stop;

@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) RCTPromiseResolveBlock startedBlock;
@property (nonatomic, weak) RCTEventEmitter *parentManager;

// RCTEventEmitter defines a weak reference to `bridge`, which will be collected
// without us retaining a separate strong reference for the lifetime of the worker.
@property (nonatomic, strong) RCTBridge *strongBridge;
@end
