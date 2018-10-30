//
//  LHRouterCenter.h
//  LHRouter
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@protocol LHRouterCenterProtocol <NSObject>

+ (NSString *)lh_routerURL;
+ (BOOL)lh_showFromViewController:(nonnull UIViewController *)controller withUserInfo:(nullable NSDictionary *)userInfo;

@end

@interface LHRouterCenter : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

- (BOOL)openURL:(nonnull NSString *)url fromViewController:(nullable UIViewController *)controller withUserInfo:(nullable NSDictionary *)userInfo;

@end
