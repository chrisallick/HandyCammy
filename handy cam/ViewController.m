//
//  ViewController.m
//  handy cam
//
//  Created by chrisallick on 1/30/15.
//  Copyright (c) 2015 chrisallick. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cv = [[CameraView alloc] initWithFrame:self.view.frame];
    [cv setCameraViewDelegate:self];
    [self.view addSubview:cv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Misc Methods

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
