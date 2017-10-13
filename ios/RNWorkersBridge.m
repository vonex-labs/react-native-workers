#import "RNWorkersBridge.h"

@implementation RNWorkersBridge

// Upon reload, workers will be reinitialized by the root JavaScript context.
// Existing bridges need to be invalidated and freed, lest they compete with
// the new worker instances for access to the remote debugger.
- (void)didReceiveReloadCommand
{
  [self invalidate];
}

@end
