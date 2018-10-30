//
//  ViewController.m
//  RouterDemo
//
//  Created by Noah on 2018/6/20.
//  Copyright © 2018年 Noah. All rights reserved.
//

#import "ViewController.h"
#import "LHRouterCenter.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *label = [UILabel new];
    label.text = @"Tap me!";
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        (void)make.center;
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(show)];
    [self.view addGestureRecognizer:tap];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)show {
    if (arc4random() % 2) {
        [[LHRouterCenter sharedInstance] openURL:@"lh://first?title=&content=Hello World" fromViewController:nil withUserInfo:nil];
    } else {
        [[LHRouterCenter sharedInstance] openURL:@"SecondViewController" fromViewController:self withUserInfo:@{ @"image": [UIImage new] }];
    }
}


@end
