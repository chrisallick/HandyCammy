//
//  ViewController.h
//  handy cam
//
//  Created by chrisallick on 1/30/15.
//  Copyright (c) 2015 chrisallick. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraView.h"

@interface ViewController : UIViewController <CameraViewDelegate> {
    CameraView *cv;
}


@end

