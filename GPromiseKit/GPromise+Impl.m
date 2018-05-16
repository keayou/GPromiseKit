//
//  GPromise+Impl.m
//  GPromiseKit
//
//  Created by GIKI on 2018/5/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromise+Impl.h"
#import "GPromiseInternal.h"
@implementation GPromise (Impl)

@end

@implementation GPromise (then)

- (GPromise*)then:(GPromiseThenBlock)block
{
    return [self then:block invokeQueue:[GPromise currentQueue]];
}
            
- (GPromise*)then:(GPromiseThenBlock)block invokeQueue:(dispatch_queue_t)queue
{
    return [self invokeChainsOnQueue:queue fulfill:block reject:nil];
}

@end

@implementation GPromise (catchError)

- (GPromise*)catchError:(GPromiseCatchBlock)block
{
    return  [self catchError:block invokeQueue:[GPromise currentQueue]];
}
- (GPromise*)catchError:(GPromiseCatchBlock)block invokeQueue:(dispatch_queue_t)queue
{
    return [self invokeChainsOnQueue:queue fulfill:nil reject:^id(NSError *error) {
                                                                    block(error);
                                                                    return error;
                                                                }];
}

@end

@implementation GPromise (finally)

- (GPromise*)finally:(GPromiseFinallyBlock)block
{
    return [self finally:block invokeQueue:GPromiseDefulatQueue];
}

- (GPromise*)finally:(GPromiseFinallyBlock)block invokeQueue:(dispatch_queue_t)queue
{
    return [self invokeChainsOnQueue:queue fulfill:^id(id value) {
                                            block();
                                            return value;
                                        } reject:^id(NSError *error) {
                                            block();
                                            return error;
                                        }];
}

@end

@implementation GPromise (after)

- (GPromise *)after:(NSTimeInterval)interval
{
    return  [self after:interval invokeQueue:GPromiseDefulatQueue];
}

- (GPromise *)after:(NSTimeInterval)interval invokeQueue:(dispatch_queue_t)queue
{
    GPromise *promise = [GPromise promise];
    [self doProcessPromiseOnQueue:queue fulfill:^(id value) {
        dispatch_after(dispatch_time(0, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
            [promise fulfill:value];
        });
    } reject:^(NSError *error) {
         [promise reject:error];
    }];
    return promise;
}

@end

@implementation GPromise (timeout)
- (GPromise *)timeout:(NSTimeInterval)interval
{
    return  [self timeout:interval invokeQueue:GPromiseDefulatQueue];
}

- (GPromise *)timeout:(NSTimeInterval)interval invokeQueue:(dispatch_queue_t)queue
{
    GPromise *promise = [GPromise promise];
    [self doProcessPromiseOnQueue:queue fulfill:^(id value) {
        [promise fulfill:value];
    } reject:^(NSError *error) {
        [promise reject:error];
    }];
    __weak typeof(self) weakSelf = promise;
    dispatch_after(dispatch_time(0, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
        NSError *timedOutError = GPromiseErrorCode(2, @"promise--timeout");
        [weakSelf reject:timedOutError];
    });
    return promise;
}

@end

@implementation GPromise (async)

+ (GPromise*)async:(GPromiseAsyncBlock)block
{
    return  [self async:block invokeQueue:GPromiseDefulatQueue];
}

+ (GPromise*)async:(GPromiseAsyncBlock)block invokeQueue:(dispatch_queue_t)queue
{
    GPromise *promise = [GPromise promise];
    dispatch_group_async(GPromiseDefulatGroup, queue, ^{
        block(^(id value) {
            if (GPromiseClass(value)) {
                GPromise *promiseT = (GPromise*)value;
                [promiseT doProcessPromiseOnQueue:queue fulfill:^(id value) {
                    [promise fulfill:value];
                } reject:^(NSError *error) {
                    [promise reject:error];
                }];
            } else {
                [promise fulfill:value];
            }
        },^(NSError *error) {
            [promise reject:error];
        });
    });
    return promise;
}

@end

@implementation GPromise(inovke)
+ (GPromise*)inovke:(GPromiseInvokeBlock)block
{
    return [self inovke:block invokeQueue:GPromiseDefulatQueue];
}

+ (GPromise*)inovke:(GPromiseInvokeBlock)block invokeQueue:(dispatch_queue_t)queue
{
    GPromise *promise = [GPromise promise];
    dispatch_group_async(GPromiseDefulatGroup, queue, ^{
        id value = block();
        if (GPromiseClass(value)) {
            GPromise *promiseT = (GPromise*)value;
            [promiseT doProcessPromiseOnQueue:queue fulfill:^(id value) {
                [promise fulfill:value];
            } reject:^(NSError *error) {
                [promise reject:error];
            }];
        } else {
            [promise fulfill:value];
        }
    });
    return promise;
}

@end

@implementation GPromise (all)

+ (GPromise*)all:(NSArray*)promises
{
    return  [self all:promises invokeQueue:GPromiseDefulatQueue];
}

+ (GPromise*)all:(NSArray*)promises invokeQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(queue);
    NSParameterAssert(promises);
    if (!promises || promises.count == 0) {
        return [GPromise resolved:@[]];
    }
    NSMutableArray * promisesM = [promises mutableCopy];
    GPromise *promise = [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject) {
        
        for (NSUInteger i = 0; i < promisesM.count; ++i) {
            id promiseT = promisesM[i];
            if (GPromiseClass(promiseT)) {
                continue;
            } else if (GPromiseErrorClass(promiseT)) {
                reject(promiseT);
                return;
            } else {
                [promisesM replaceObjectAtIndex:i
                                    withObject:[GPromise resolved:promiseT]];
            }
        }
        for (GPromise *promiseT in promisesM) {
            [promiseT doProcessPromiseOnQueue:queue fulfill:^(id value) {
                // Wait until all are fulfilled.
                for (GPromise *promise in promises) {
                    if (![promise isFulfill]) {
                        return;
                    }
                }
                fulfill([promises valueForKey:NSStringFromSelector(@selector(value))]);
            } reject:^(NSError *error) {
                reject(error);
            }];
        }
    } invokeQueue:queue];
    return  promise;
}

@end

@implementation GPromise (any)

+ (GPromise*)any:(NSArray*)promises
{
    return  [GPromise any:promises invokeQueue:GPromiseDefulatQueue];
}

+ (GPromise*)any:(NSArray*)promises invokeQueue:(dispatch_queue_t)queue
{
    if (promises.count == 0) {
        return [GPromise resolved:@[]];
    }
    NSMutableArray *promisesM = [promises mutableCopy];
    return [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject) {
        for (NSUInteger i = 0; i < promisesM.count; ++i) {
            id promiseT = promises[i];
            if (GPromiseClass(promiseT)) {
                continue;
            } else {
                [promisesM replaceObjectAtIndex:i
                                    withObject:[GPromise resolved:promiseT]];
            }
        }
        for (GPromise *promise in promisesM) {
            [promise doProcessPromiseOnQueue:queue fulfill:^(id value) {
        
                for (GPromise *promise in promisesM) {
                    if (promise.isPending) {
                        return;
                    }
                }
                fulfill([GPromiseUtil filterPromiseReturnValues:promises]);
            } reject:^(NSError *error) {
                BOOL fulfilled = NO;
                for (GPromise *promise in promises) {
                    if ([promise isPending]) {
                        return;
                    }
                    if ([promise isFulfill]) {
                        fulfilled = YES;
                    }
                }
                if (fulfilled) {
                    fulfill([GPromiseUtil filterPromiseReturnValues:promises]);
                } else {
                    reject(error);
                }
            }];
        }
    } invokeQueue:queue];
   
}

@end

