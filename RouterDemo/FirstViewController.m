//
//  FirstViewController.m
//  RouterDemo
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import "FirstViewController.h"
#import <LHRouter/LHRouterCenter.h>

@interface FirstViewController () <LHRouterCenterProtocol>

@end

@implementation FirstViewController

+ (NSString *)lh_routerURL
{
    return @"lh://first";
}

+ (BOOL)lh_showFromViewController:(UIViewController *)controller withUserInfo:(NSDictionary *)userInfo
{
    UIViewController *vc = [[self alloc] init];
    [controller.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"%s %@", __func__, userInfo);

    return YES;
}

@end
