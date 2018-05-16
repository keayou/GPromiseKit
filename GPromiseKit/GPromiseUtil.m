//
//  GPromiseUtil.m
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromiseUtil.h"
#import "GPromiseInternal.h"
@implementation GPromiseUtil

+ (dispatch_group_t)dispatchGroup
{
    static dispatch_group_t dispatchGroupPrivate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatchGroupPrivate = dispatch_group_create();
    });
    return dispatchGroupPrivate;
}

+ (NSArray*)filterPromiseReturnValues:(NSArray*)promises
{
    NSMutableArray *combinedValuesAndErrors = [[NSMutableArray alloc] init];
    for (GPromise *promise in promises) {
        if (promise.isFulfill) {
            [combinedValuesAndErrors addObject:promise.value ?: [NSNull null]];
            continue;
        }
        if (promise.isReject) {
            [combinedValuesAndErrors addObject:promise.error];
            continue;
        }
        assert(!promise.isPending);
    };
    return combinedValuesAndErrors;
}

+ (NSError*)generateErrorWithDomain:(NSString*)domain code:(NSInteger)code userinfo:(id)userInfo
{
    NSError *error = [NSError errorWithDomain:domain?:GPromiseErrorDomain code:code userInfo:userInfo];
    return error;
}
@end

