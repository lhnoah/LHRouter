//
//  SecondViewController.m
//  RouterDemo
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import "SecondViewController.h"
#import <LHRouter/LHRouterCenter.h>

@interface SecondViewController () <LHRouterCenterProtocol>

@end

@implementation SecondViewController

+ (NSString *)lh_routerURL
{
    return @"lh://second";
}

+ (BOOL)lh_showFromViewController:(UIViewController *)controller withUserInfo:(NSDictionary *)userInfo
{
    UIViewController *vc = [[self alloc] init];
    [controller presentViewController:vc animated:YES completion:nil];
    
    NSLog(@"%s %@", __func__, userInfo);

    return YES;
}

@end
