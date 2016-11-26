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

@property (strong, nonatomic) UIBarButtonItem *toggleIntervalRateButton;
@property (strong, nonatomic) UIBarButtonItem *mRRButton;
@property (strong, nonatomic) UIBarButtonItem *qtcButton;
@property (strong, nonatomic) UIBarButtonItem *calibrateCalipersButton;
@property (strong, nonatomic) UIBarButtonItem *previousPageButton;
@property (strong, nonatomic) UIBarButtonItem *nextPageButton;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;
@property (strong, nonatomic) UIBarButtonItem *brugadaButton;

@property (strong, nonatomic) NSArray *mainMenuItems;
@property (strong, nonatomic) NSArray *photoMenuItems;
@property (strong, nonatomic) NSArray *calipersMenuItems;
@property (strong, nonatomic) NSArray *adjustImageMenuItems;
@property (strong, nonatomic) NSArray *moreAdjustImageMenuItems;
@property (strong, nonatomic) NSArray *addCalipersMenuItems;
@property (strong, nonatomic) NSArray *calibrateMenuItems;
@property (strong, nonatomic) NSArray *qtcStep1MenuItems;
@property (strong, nonatomic) NSArray *qtcStep2MenuItems;

@property (strong, nonatomic) Calibration *horizontalCalibration;
@property (strong, nonatomic) Calibration *verticalCalibration;
@property (strong, nonatomic) Settings *settings;

@property (nonatomic) BOOL isIpad;
@property (nonatomic) double rrIntervalForQTc;
@property (nonatomic) BOOL firstRun;
@property (nonatomic) BOOL launchFromURL;
@property (strong, nonatomic) NSURL *launchURL;

@property (nonatomic) BOOL isCalipersView;

@property (nonatomic) CGFloat sizeDiffWidth;
@property (nonatomic) CGFloat sizeDiffHeight;

@property (nonatomic) CGFloat lastZoomFactor;
@property (nonatomic) BOOL isRotatedImage;

@property (nonatomic) CGFloat portraitWidth;
@property (nonatomic) CGFloat portraitHeight;
@property (nonatomic) CGFloat landscapeWidth;
@property (nonatomic) CGFloat landscapeHeight;

- (void)openURL:(NSURL *)url;

//@property (nonatomic) CGPDFDocumentRef documentRef;
@property (nonatomic) int pageNumber;
@property (nonatomic) int numberOfPages;

@property (nonatomic) BOOL defaultHorizontalCalChanged;
@property (nonatomic) BOOL defaultVerticalCalChanged;

@end

