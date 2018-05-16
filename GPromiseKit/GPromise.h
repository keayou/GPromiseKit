//
//  GPromise.h
//  GPromiseKit
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPromise : NSObject

/**
 create a promise in pending
 */
+ (instancetype)promise;

/**
 create a promise in fulfill or reject
 @param value fulfill value or reject error
 */
+ (instancetype)resolved:(id)value;

/**
 fulfill It can be recognized that it is a successful implementation
 */
- (void)fulfill:(id)value;

/**
 reject It can be recognized that it is a failure implementation
 */
- (void)reject:(NSError *)error;


/**
 Configure a queue invoke promise

 defaultQueue is mainQueue
 */
+ (void)configDefaultQueue:(dispatch_queue_t)queue;

/**
 Get the current queue
 */
+ (dispatch_queue_t)currentQueue;

@end
