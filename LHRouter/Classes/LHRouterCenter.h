//
//  LHRouterCenter.h
//  LHRouter
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    LHRouterCenterErrorInvalidInput = -1,
    LHRouterCenterErrorUnknownURL   = -2,
    LHRouterCenterErrorNoResponder  = -3,
} LHRouterCenterError;

@class UIViewController;

@protocol LHRouterCenterProtocol <NSObject>

@required
+ (BOOL)lh_showFromViewController:(nonnull UIViewController *)controller withUserInfo:(nullable NSDictionary *)userInfo;

@optional
+ (NSString *)lh_routerURL; // Default is class name if not implemented

@end

@interface LHRouterCenter : NSObject

+ (instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)canOpenURL:(nonnull NSString *)url error:(NSError **)error;
- (BOOL)openURL:(nonnull NSString *)url fromViewController:(nullable UIViewController *)controller withUserInfo:(nullable NSDictionary *)userInfo;

@end
