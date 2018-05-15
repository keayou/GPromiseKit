//
//  GPromise.h
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPromise : NSObject

+ (instancetype)promise;
+ (instancetype)resolved:(id)value;

- (void)fulfill:(id)value;
- (void)reject:(NSError *)error;

+ (void)configDefaultQueue:(dispatch_queue_t)queue;
+ (dispatch_queue_t)currentQueue;

@end
