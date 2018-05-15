//
//  GPromise+Impl.h
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromise.h"
#import "GPromiseUtil.h"

@interface GPromise (Impl)

@end

@interface GPromise (then)
- (GPromise*)then:(GPromiseThenBlock)block;
- (GPromise*)then:(GPromiseThenBlock)block invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(catchError)
- (GPromise*)catchError:(GPromiseCatchBlock)block;
- (GPromise*)catchError:(GPromiseCatchBlock)block invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(finally)
- (GPromise*)finally:(GPromiseFinallyBlock)block;
- (GPromise*)finally:(GPromiseFinallyBlock)block invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(after)
- (GPromise *)after:(NSTimeInterval)interval;
- (GPromise *)after:(NSTimeInterval)interval invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(timeout)
- (GPromise *)timeout:(NSTimeInterval)interval;
- (GPromise *)timeout:(NSTimeInterval)interval invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(async)
+ (GPromise*)async:(GPromiseAsyncBlock)block;
+ (GPromise*)async:(GPromiseAsyncBlock)block invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(all)
+ (GPromise*)all:(NSArray*)promises;
+ (GPromise*)all:(NSArray*)promises invokeQueue:(dispatch_queue_t)queue;
@end

@interface GPromise(any)
+ (GPromise*)any:(NSArray*)promises;
+ (GPromise*)any:(NSArray*)promises invokeQueue:(dispatch_queue_t)queue;
@end




