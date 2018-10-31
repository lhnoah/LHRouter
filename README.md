# LHRouter

A smart iOS URL Router.

## Installation

- using CocoaPods

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](http://cocoapods.org/#get_started) section for more details.

#### Podfile
```
pod 'LHRouter'
```

## How To Use

```objective-c
#import <LHRouter/LHRouterCenter.h>

// Implement LHRouterCenterProtocol in a UIViewController

+ (NSString *)lh_routerURL // @optional
{
    return @"lh://router";
}

+ (BOOL)lh_showFromViewController:(UIViewController *)controller 
                     withUserInfo:(NSDictionary *)userInfo
{
    UIViewController *vc = [[self alloc] init];
    [controller presentViewController:vc animated:YES completion:nil];
    NSLog(@"%s %@", __func__, userInfo);
    return YES;
}


// Call the following method in an other UIViewController

[[LHRouterCenter sharedInstance] openURL:@"lh://router?title=&content=Hello World"
                      fromViewController:nil 
                            withUserInfo:nil];
```
