//
//  EPSMainViewController.h
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalipersView.h"
#import "Calibration.h"
#import "Settings.h"

@interface EPSMainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet CalipersView *calipersView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;
@property (strong, nonatomic) UIImage *originalImage;

@property (strong, nonatomic) UIBarButtonItem *toggleIntervalRateButton;
@property (strong, nonatomic) UIBarButtonItem *mRRButton;
@property (strong, nonatomic) UIBarButtonItem *qtcButton;

@property (strong, nonatomic) NSArray *mainMenuItems;
@property (strong, nonatomic) NSArray *photoMenuItems;
@property (strong, nonatomic) NSArray *calipersMenuItems;
@property (strong, nonatomic) NSArray *adjustImageMenuItems;
@property (strong, nonatomic) NSArray *addCalipersMenuItems;
@property (strong, nonatomic) NSArray *calibrateMenuItems;
@property (strong, nonatomic) NSArray *qtcStep1MenuItems;
@property (strong, nonatomic) NSArray *qtcStep2MenuItems;

@property (strong, nonatomic) Calibration *horizontalCalibration;
@property (strong, nonatomic) Calibration *verticalCalibration;
@property (strong, nonatomic) Settings *settings;

@property BOOL isIpad;
@property double rrIntervalForQTc;

@property BOOL isCalipersView;

@property float sizeDiffWidth;
@property float sizeDiffHeight;

@property CGFloat lastZoomFactor;

@end

