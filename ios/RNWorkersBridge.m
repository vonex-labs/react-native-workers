#import "RNWorkersBridge.h"
#import "RNWorkersDevSettings.h"
#import <React/RCTDevSettings.h>

@implementation RNWorkersBridge

- (RCTDevSettings *)devSettings
{
#if RCT_DEV
  return [self moduleForClass:[RNWorkersDevSettings class]];
#else
  return nil;
#endif
}

@end
