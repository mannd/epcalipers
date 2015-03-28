//
//  ViewController.h
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalipersView.h"
#import "Calibration.h"
#import "Settings.h"

@interface EPSMainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UINavigationBarDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet CalipersView *calipersView;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property NSArray *mainMenuItems;
@property NSArray *photoMenuItems;
@property NSArray *calipersMenuItems;
@property NSArray *adjustImageMenuItems;
@property NSArray *addCalipersMenuItems;
@property NSArray *calibrateMenuItems;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;

@property (strong, nonatomic) Calibration *horizontalCalibration;
@property (strong, nonatomic) Calibration *verticalCalibration;
@property (strong, nonatomic) Settings *settings;

- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;


@end

