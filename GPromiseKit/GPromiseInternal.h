//
//  GPromiseInternal.h
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromise.h"
#import "GPromiseUtil.h"

static dispatch_queue_t dispatchQueuePrivate;

@interface GPromise()

- (void)doProcessPromiseOnQueue:(dispatch_queue_t)queue fulfill:(GPromiseFulfillBlock)fulfillBlock reject:(GPromiseRejectBlock)rejectBlock;
- (GPromise*)invokeChainsOnQueue:(dispatch_queue_t)queue fulfill:(GPromiseFulfilledBlock)fulfilled reject:(GPromiseRejectedBlock)rejected;

- (BOOL)isPending;
- (BOOL)isFulfill;
- (BOOL)isReject;
@end
