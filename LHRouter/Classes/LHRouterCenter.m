//
//  LHRouterCenter.m
//  LHRouter
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import "LHRouterCenter.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define FLAG 1

@interface LHRouterCenter ()

@property (strong, nonatomic) NSDictionary *routerTable;

@end

@implementation LHRouterCenter

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (instancetype)sharedInstance
{
    static LHRouterCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

+ (BOOL)gotoViewController:(Class)class fromViewController:(UIViewController *)controller withUserInfo:(NSDictionary *)userInfo
{
    if (!class || !controller) {
        return NO;
    }

    SEL selector = @selector(lh_showFromViewController:withUserInfo:);

#if !DEBUG
    if (![class respondsToSelector:selector]) {
        return NO;
    }
#endif

    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
    if (signature && !strcmp(signature.methodReturnType, @encode(BOOL))) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = class;
        invocation.selector = selector;
        [invocation setArgument:&controller atIndex:2];
        [invocation setArgument:&userInfo atIndex:3];
        [invocation invoke];

        BOOL value = NO;
        [invocation getReturnValue:&value];

        return value;
    }

    return NO;
}

+ (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[self sharedInstance] routerTable];
    });
}

- (BOOL)canOpenURL:(nonnull NSString *)url error:(NSError **)error
{
    NSErrorDomain domain = [NSStringFromClass(self.class) stringByAppendingString:@"ErrorDomain"];

    if (![url isKindOfClass:NSString.class]) {
        if (error) {
            *error = [NSError errorWithDomain:domain code:LHRouterCenterErrorInvalidInput userInfo:nil];
        }

        return NO;
    }

    Class class = [self classFromURL:url];

    if (!class) {
        if (error) {
            *error = [NSError errorWithDomain:domain code:LHRouterCenterErrorUnknownURL userInfo:nil];
        }

        return NO;
    }

    SEL selector = @selector(lh_showFromViewController:withUserInfo:);

    if (![class respondsToSelector:selector]) {
        if (error) {
            *error = [NSError errorWithDomain:domain code:LHRouterCenterErrorNoResponder userInfo:nil];
        }

        return NO;
    }

    if (error) {
        *error = nil;
    }

    return YES;
}

- (BOOL)openURL:(nonnull NSString *)url fromViewController:(nullable UIViewController *)controller withUserInfo:(nullable NSDictionary *)userInfo
{
    if (![url isKindOfClass:NSString.class]) {
        return NO;
    }
    
    NSMutableDictionary *parameters = [self parametersFromURL:url];
    [parameters addEntriesFromDictionary:userInfo];

    return [self.class gotoViewController:[self classFromURL:url] fromViewController:(controller ? controller : [self topViewController]) withUserInfo:parameters];
}

- (Class)classFromURL:(NSString *)url
{
    NSString *host = [self hostFromURL:url];
    NSString *class = self.routerTable[host];
    if (!class.length) {
        class = host;
    }

    return NSClassFromString(class);
}

- (NSString *)hostFromURL:(NSString *)url
{
    NSRange range = [url rangeOfString:@"?"];
    
    return range.location == NSNotFound ? url : [url substringToIndex:range.location];
}

- (NSMutableDictionary *)parametersFromURL:(NSString *)url
{
    NSRange range = [url rangeOfString:@"?"];
    
    if (range.location == NSNotFound) {
        return [NSMutableDictionary new];
    }
    
    NSString *string = [url substringFromIndex:range.location + 1];
    NSArray *array = [string componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (NSString *str in array) {
        range = [str rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *key = [str substringToIndex:range.location];
            NSString *value = [str substringFromIndex:range.location + 1];
            [parameters setValue:value forKey:key];
        }
    }
    
    return parameters;
}

- (UIViewController *)topViewController
{
    UIViewController *controller;
    controller = [self _topViewController:[[UIApplication sharedApplication].delegate.window rootViewController]];
    while (controller.presentedViewController) {
        controller = [self _topViewController:controller.presentedViewController];
    }

    return controller;
}

- (UIViewController *)_topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)controller topViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)controller selectedViewController]];
    } else {
        return controller;
    }
}

- (NSDictionary *)routerTable
{
    if (!_routerTable) {
#if DEBUG
        NSDate *date = [NSDate date];
#endif
#if !(DEBUG && FLAG)
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [NSString stringWithFormat:@"%@_%@", info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"]];
        NSString *key = [NSString stringWithFormat:@"%@.%@", info[@"CFBundleIdentifier"], NSStringFromClass(self.class)];
        NSDictionary *dic = [[[NSUserDefaults standardUserDefaults] objectForKey:key] objectForKey:version];

        if ([dic isKindOfClass:[NSDictionary class]]) {
            @synchronized (self) {
                if (!_routerTable) {
                    _routerTable = dic;
                }
            }
        } else {
#endif
            // UIWebView的initialize方法必须在主线程调用，此处调用class或hash方法来触发initialize方法
            if ([NSThread currentThread].isMainThread) {
                [UIWebView class];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [UIWebView hash];
                });
            }

            @synchronized (self) {
                if (!_routerTable) {
                    NSInteger count = 0;
                    _routerTable = [self fetchSchema:&count];
#if DEBUG
                    NSLog(@"%s elapsed time: %f, count of classes: %@", __func__, -[date timeIntervalSinceNow], @(count));
#endif
#if !(DEBUG && FLAG)
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:_routerTable forKey:version] forKey:key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
#endif
            }
        }
    }

    return _routerTable;
}

- (NSDictionary *)fetchSchema:(NSInteger *)count
{
    NSMutableDictionary *mutableDic = [NSMutableDictionary new];
    unsigned _classCount = 0;
    NSString *appBundle = [NSBundle mainBundle].executablePath;
    const char **_allClassNames = objc_copyClassNamesForImage([appBundle UTF8String], &_classCount);
    SEL selector = @selector(lh_routerURL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(_classCount, DISPATCH_APPLY_AUTO, ^(size_t i) {
        const char *_className = _allClassNames[i];
        NSString *name = [NSString stringWithUTF8String:_className];
        Class class = NSClassFromString(name);

        if (![class respondsToSelector:selector]) {
            return;
        }

        NSMethodSignature *signature = [class methodSignatureForSelector:selector];
        if (signature && !strcmp(signature.methodReturnType, @encode(id))) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = class;
            invocation.selector = selector;
            [invocation invoke];

            __autoreleasing id value = nil;
            [invocation getReturnValue:&value];

            if ([value isKindOfClass:[NSString class]]) {
                NSAssert([value rangeOfString:@"?"].location == NSNotFound, @"Do not contain '?' in the return value of [%@ %@]", name, NSStringFromSelector(selector));
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [mutableDic setObject:name forKey:value];
                dispatch_semaphore_signal(semaphore);
            }
        }
    });
    free(_allClassNames);
    *count = _classCount;

    return [mutableDic copy];
}

@end
