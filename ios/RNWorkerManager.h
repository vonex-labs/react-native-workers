#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTInvalidating.h>

@interface RNWorkerManager : RCTEventEmitter <RCTBridgeModule, RCTInvalidating>
@end
