//
//  GPromiseUtil.m
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GPromiseUtil.h"

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

@end

