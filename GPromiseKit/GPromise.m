//
//  GPromise.m
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromise.h"
#import "GPromiseInternal.h"


@interface GPromise()
@property (nonatomic, assign) GPromiseState currentState;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError * error;
@property (nonatomic, strong) NSMutableArray<GPromiseTask> * taskArray;
@end



@implementation GPromise

+ (void)initialize
{
    if (self == [GPromise class]) {
        dispatchQueuePrivate = dispatch_get_main_queue();
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_group_enter(GPromiseDefulatGroup);
    }
    return self;
}

- (instancetype)initWithResoved:(id)value {
    self = [super init];
    if (self) {
        if ([value isKindOfClass:[NSError class]]) {
            _currentState = GPromiseState_Reject;
            _error = (NSError *)value;
        } else {
            _currentState = GPromiseState_Fulfill;
            _value = value;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_currentState == GPromiseState_Pending) {
        dispatch_group_leave(GPromiseDefulatGroup);
    }
}


- (NSMutableArray<GPromiseTask> *)taskArray
{
    if (!_taskArray) {
        _taskArray = [NSMutableArray array];
    }
    return _taskArray;
}

#pragma mark - private Method

- (BOOL)isPending
{
    @synchronized(self) {
        return _currentState == GPromiseState_Pending;
    }
}

- (BOOL)isFulfill
{
    @synchronized(self) {
        return _currentState == GPromiseState_Fulfill;
    }
}

- (BOOL)isReject
{
    @synchronized(self) {
        return _currentState == GPromiseState_Reject;
    }
}

- (void)processValue:(id)value error:(NSError*)error state:(GPromiseState)state
{
//    NSAssert(value==nil&&error==nil, @"value and error Cannot be empty at the same time");
    _currentState = state;
    _value = value;
    _error = error;
    [self.taskArray enumerateObjectsUsingBlock:^(GPromiseTask  _Nonnull taskInvoke, NSUInteger idx, BOOL * _Nonnull stop) {
        if (taskInvoke) {
            if (value) {
                taskInvoke(_currentState,_value);
            } else {
                taskInvoke(_currentState,_error);
            }
        }
    }];
    self.taskArray = nil;
    dispatch_group_leave(GPromiseDefulatGroup);
}

- (void)doProcessPromiseOnQueue:(dispatch_queue_t)queue fulfill:(GPromiseFulfillBlock)fulfillBlock reject:(GPromiseRejectBlock)rejectBlock
{
    NSParameterAssert(queue);
    NSParameterAssert(fulfillBlock);
    NSParameterAssert(rejectBlock);
    dispatch_group_t groupPromise = GPromiseDefulatGroup;
    if (queue==nil) {
        queue = dispatchQueuePrivate;
    }
    @synchronized(self) {
        switch (_currentState) {
            case GPromiseState_Pending: {
                [self.taskArray addObject:^(GPromiseState state, id value) {
                    dispatch_group_async(groupPromise, queue, ^{
                        switch (state) {
                            case GPromiseState_Pending:
                                break;
                            case GPromiseState_Fulfill:
                                if (fulfillBlock) {
                                  fulfillBlock(value);
                                }
                                break;
                            case GPromiseState_Reject:
                                if (rejectBlock) {
                                    rejectBlock(value);
                                }
                                break;
                        }
                    });
                }];
                break;
            }
            case GPromiseState_Fulfill: {
                dispatch_group_async(groupPromise, queue, ^{
                    if (fulfillBlock) {
                       fulfillBlock(self.value);
                    }
                });
                break;
            }
            case GPromiseState_Reject: {
                dispatch_group_async(groupPromise, queue, ^{
                    if (rejectBlock) {
                        rejectBlock(self.error);
                    }
                });
                break;
            }
        }
    }
}

- (GPromise*)invokeChainsOnQueue:(dispatch_queue_t)queue fulfill:(GPromiseFulfilledBlock)fulfilled reject:(GPromiseRejectedBlock)rejected
{
    if (queue==nil) queue = dispatchQueuePrivate;
    
    GPromise *promise = [GPromise promise];
    __auto_type resolver = ^(id value) {
        if ([value isKindOfClass:[GPromise class]]) {
            GPromise *tempPromise = (GPromise *)value;
            [tempPromise doProcessPromiseOnQueue:queue fulfill:^(id value) {
                [promise fulfill:value];
            } reject:^(NSError *error) {
                [promise reject:error];
            }];
        } else {
            [promise fulfill:value];
        }
    };
    
    [self doProcessPromiseOnQueue:queue fulfill:^(id value) {
        value = fulfilled ? fulfilled(value) : value;
        resolver(value);
    } reject:^(NSError *error) {
        id value = rejected ? rejected(error) : error;
        resolver(value);
    }];
    
    return promise;
}

#pragma mark - public Method

+ (instancetype)promise
{
    return [[GPromise alloc] init];
}

+ (instancetype)resolved:(id)value
{
    return [[GPromise alloc] initWithResoved:value];
}

- (void)fulfill:(id)value
{
    if (GPromiseErrorClass(value)) {
        [self reject:value];
    } else {
        @synchronized(self) {
            if (_currentState == GPromiseState_Pending) {
                 [self processValue:value error:nil state:GPromiseState_Fulfill];
            }
        }
    }
}

- (void)reject:(NSError *)error
{
    if (!GPromiseErrorClass(error)) {
        @throw error;
    }
    @synchronized(self) {
        if (_currentState == GPromiseState_Pending) {
          [self processValue:nil error:error state:GPromiseState_Fulfill];
        }
    }
}

+ (void)configDefaultQueue:(dispatch_queue_t)queue
{
    @synchronized(self) {
        dispatchQueuePrivate = queue;
    }
}

+ (dispatch_queue_t)currentQueue
{
    @synchronized(self) {
        return dispatchQueuePrivate;
    }
}
@end
