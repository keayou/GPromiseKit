//
//  GPromiseUtil.h
//  GPromiseKit
//
//  Created by GIKI on 2018/5/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define GPromiseErrorDomain  @"GPromise.Error.domain"

#define GPromiseErrorClass(value) ([value isKindOfClass:[NSError class]])
#define GPromiseClass(value) ([value isKindOfClass:[GPromise class]])

#define GPromiseErrorCode(codeValue,info) [GPromiseUtil generateErrorWithDomain:GPromiseErrorDomain code:codeValue userinfo:info]
#define GPromiseError(info) [GPromiseUtil generateErrorWithDomain:GPromiseErrorDomain code:0 userinfo:info]

#define GPromiseDefulatQueue [GPromise currentQueue]
#define GPromiseDefulatGroup [GPromiseUtil dispatchGroup]

typedef NS_ENUM(NSInteger, GPromiseState) {
    GPromiseState_Pending = 0,
    GPromiseState_Fulfill,
    GPromiseState_Reject,
};

typedef void (^GPromiseTask)(GPromiseState state, id value);
typedef void (^GPromiseFulfillBlock)(id value);
typedef void (^GPromiseRejectBlock)(NSError *error);
typedef id (^GPromiseFulfillReturnBlock)(id value);
typedef id (^GPromiseRejectReturnBlock)(NSError *error);
typedef id (^GPromiseThenBlock)(id value);
typedef void (^GPromiseCatchBlock)(NSError *error);
typedef void (^GPromiseAsyncBlock)(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject);
typedef id (^GPromiseInvokeBlock)(void);
typedef void (^GPromiseFinallyBlock)(void);

@interface GPromiseUtil : NSObject

+ (dispatch_group_t)dispatchGroup;

+ (NSArray*)filterPromiseReturnValues:(NSArray*)promises;

+ (NSError*)generateErrorWithDomain:(NSString*)domain code:(NSInteger)code userinfo:(id)userInfo;
@end
