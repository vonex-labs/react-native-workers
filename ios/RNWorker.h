#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTInvalidating.h>

@interface RNWorker : RCTEventEmitter <RCTBridgeModule, RCTInvalidating>
@property (nonatomic, assign) int key;
@property (nonatomic, strong) RCTEventEmitter *parent;
@end
