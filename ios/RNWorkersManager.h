#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTInvalidating.h>

@interface RNWorkersManager : RCTEventEmitter <RCTBridgeModule, RCTInvalidating>
@end

@interface RNWorkersInstanceData : NSObject
@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *bundleRoot;
@property (nonatomic, assign) NSNumber *bundlerPort;
@property (nonatomic, strong) RCTPromiseResolveBlock startedBlock;
@property (nonatomic, weak) RNWorkersManager *parentManager;
@end
