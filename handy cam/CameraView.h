//
//  CameraView.h
//  Payper
//
//  Created by chrisallick on 7/21/14.
//  Copyright (c) 2014 chrisallick. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import "NSTimer+Blocks.h"

@protocol CameraViewDelegate
//    @required
//    -(void) didFinishSignUp;
@end

@interface CameraView : UIView <UITextFieldDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    
    UIButton *toggleFlashButton;
    
    UILabel *takePhoto;
    
    UITextField *message;
    UIButton *send;
    UIScrollView *chat;
    int msgcount;
    
    UILabel *title;
    
    BOOL bFlashOn;

    __weak id <CameraViewDelegate> cameraViewDelegate;
}

@property (nonatomic, weak) id <CameraViewDelegate> cameraViewDelegate;

@end
