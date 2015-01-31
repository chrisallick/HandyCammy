//
//  CameraView.m
//  Payper
//
//  Created by chrisallick on 7/21/14.
//  Copyright (c) 2014 chrisallick. All rights reserved.
//

#import "CameraView.h"



@implementation CameraView

@synthesize cameraViewDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeCamera];
    }
    return self;
}

- (void) initializeCamera {
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    if (!captureInput) {
        return;
    }
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    
    [captureOutput setVideoSettings:videoSettings];
    captureSession = [[AVCaptureSession alloc] init];
    
    bFlashOn = false;
    msgcount = 0;

    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    if ([captureSession canAddInput:captureInput]) {
        [captureSession addInput:captureInput];
    }
    
    //handle prevLayer
    if (!captureVideoPreviewLayer) {
        captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        // rotate and flip preview layer in one line
        // credit Quin Kennedy :)
        [captureVideoPreviewLayer setTransform:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
        
    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];

    [captureSession addOutput:stillImageOutput];
    
    //if you want to adjust the previewlayer frame, here!
    captureVideoPreviewLayer.frame = self.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer: captureVideoPreviewLayer];
    [captureSession startRunning];
    
    UIImage *toggleFlashImage = [UIImage imageNamed:@"toggleFlashButton.png"];
    toggleFlashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleFlashButton setFrame:CGRectMake(self.frame.size.width - 20 - toggleFlashImage.size.width/2.0, self.frame.size.height - 60.0 - toggleFlashImage.size.height/2.0, toggleFlashImage.size.width/2.0, toggleFlashImage.size.height/2.0)];
    [toggleFlashButton setBackgroundImage:toggleFlashImage forState:UIControlStateNormal];
    [toggleFlashButton setAdjustsImageWhenHighlighted:NO];
    [toggleFlashButton setUserInteractionEnabled:YES];
    [toggleFlashButton setTag:1];
    [toggleFlashButton addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [toggleFlashButton addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [toggleFlashButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    [toggleFlashButton addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchDragExit];
    [self addSubview:toggleFlashButton];
    
    message = [[UITextField alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 40.0, self.frame.size.width-80.0, 40.0)];
    [message setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [message setPlaceholder:@"enter message..."];
    [message setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3]];
    [self addSubview:message];
    
    chat = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 40.0, self.frame.size.width, 371.0)];
    [chat setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.1]];
    [self addSubview:chat];
    
    send = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-80.0, self.frame.size.height-40.0, 80.0, 40.0)];
    [send setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.15]];
    [send setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [send setTitle:@"send" forState:UIControlStateNormal];
    [send addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    [send setTag:2];
    [self addSubview:send];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 40.0)];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:@"Chat with Paul"];
    [self addSubview:title];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myNotificationMethod:) name:UIKeyboardWillShowNotification object:nil];
    [message becomeFirstResponder];
}

- (void)myNotificationMethod:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    [UIView beginAnimations:@"animationOn" context:NULL];
    [UIView setAnimationDuration:.290];
    [message setFrame:CGRectMake(0.0, self.frame.size.height-keyboardFrameBeginRect.size.height-40.0, self.frame.size.width, 40.0)];
    [send setFrame:CGRectMake(self.frame.size.width-80.0, self.frame.size.height-keyboardFrameBeginRect.size.height-40.0, 80.0, 40.0)];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( [textField.text length] ) {
        NSLog(@"sending usernamee");
        
        return YES;
    } else {
        return NO;
    }
}

-(void)toggleFlash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device hasTorch]) {
        [device lockForConfiguration:nil];
        if( bFlashOn ) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

-(void)onTouchUp:(UIButton *)sender {
    [UIView beginAnimations:@"animationOn" context:NULL];
    [UIView setAnimationDuration:.150];
    [sender setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

-(void)onTouchDown:(UIButton *)sender {
    [UIView beginAnimations:@"animationOn" context:NULL];
    [UIView setAnimationDuration:.150];
    [sender setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
    [UIView commitAnimations];
}

-(void)onTap:(UIButton *)sender {
    [UIView animateWithDuration: 0.300
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [sender setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {
                        if( [sender tag] == 1 ) {
                             bFlashOn = !bFlashOn;
                             if( bFlashOn ) {
                                 [toggleFlashButton setBackgroundImage:[UIImage imageNamed:@"toggleFlashButtonDown.png"] forState:UIControlStateNormal];
                             } else {
                                 [toggleFlashButton setBackgroundImage:[UIImage imageNamed:@"toggleFlashButton.png"] forState:UIControlStateNormal];
                             }
                             [self toggleFlash];
                        } else if( [sender tag] == 2) {
                            if( [[[message text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ) {
                                UILabel *newmsg = [[UILabel alloc] initWithFrame:CGRectMake(0.0, msgcount*40.0, self.frame.size.width, 40.0)];
                                [newmsg setTextColor:[UIColor whiteColor]];
                                [newmsg setTextAlignment:NSTextAlignmentLeft];
                                [newmsg setText:[message text]];
                                [chat addSubview:newmsg];
                                msgcount++;
                            }
                            
                            if( [[message text] isEqualToString:@"Hi!"] ) {
                                [NSTimer scheduledTimerWithTimeInterval:3.5 block:^{
                                    UILabel *newmsg = [[UILabel alloc] initWithFrame:CGRectMake(0.0, msgcount*40.0, self.frame.size.width, 40.0)];
                                    [newmsg setTextColor:[UIColor whiteColor]];
                                    [newmsg setText:@"wazup!"];
                                    [newmsg setTextAlignment:NSTextAlignmentRight];
                                    [chat addSubview:newmsg];
                                    msgcount++;
                                } repeats:NO];
                            }
                            
                            [message setText:@""];
                        }
                     }];
}

@end
