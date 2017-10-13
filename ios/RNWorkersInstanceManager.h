#import "RNWorkersManager.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTInvalidating.h>

@interface RNWorkersInstanceManager : RCTEventEmitter <RCTBridgeModule, RCTInvalidating>
- (instancetype)initWithData:(RNWorkersInstanceData *)data;
@end
