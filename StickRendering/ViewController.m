//
//  ViewController.m
//  StickRendering
//
//  Created by etund on 15/6/24.
//  Copyright (c) 2015年 etund. All rights reserved.
//

#import "ViewController.h"
#import "ETBubbing.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ETBubbing *bubbing = [[ETBubbing alloc] init];
    bubbing.frame = CGRectMake(30, 30, 40, 40);
    bubbing.image = [UIImage imageNamed:@"doubi"];
    bubbing.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:bubbing];
}

@end
