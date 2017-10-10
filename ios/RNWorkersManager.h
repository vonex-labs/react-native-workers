#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTInvalidating.h>

@interface RNWorkersManager : RCTEventEmitter <RCTBridgeModule, RCTInvalidating>
@end
