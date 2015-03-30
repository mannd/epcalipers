//
//  EPSMainViewController.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "EPSMainViewController.h"
#import "Caliper.h"
#import "Settings.h"
#import "EPSLogging.h"

#define ANIMATION_DURATION 0.5

@interface EPSMainViewController ()

@end

@implementation EPSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.settings = [[Settings alloc] init];
    
    [self createMainToolbar];
    [self createImageToolbar];
    [self createAdjustImageToolbar];
    [self createAddCalipersToolbar];
    [self createSetupCalibrationToolbar];
    
    [self selectMainToolbar];
 
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    [self.scrollView setZoomScale:1.0];
    
    self.horizontalCalibration = [[Calibration alloc] init];
    self.horizontalCalibration.direction = Horizontal;

    self.verticalCalibration = [[Calibration alloc] init];
    self.verticalCalibration.direction = Vertical;
    
    [self.calipersView setUserInteractionEnabled:YES];
    
    // add a Caliper to start out
    [self addHorizontalCaliper];
    
    EPSLog(@"view h = %f, view w = %f", self.view.frame.size.height, self.view.frame.size.width);
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    EPSLog(@"orientation is %ld", orientation);
    
    // detect orientation changes to change calibration on the fly
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

}

- (void)viewDidAppear:(BOOL)animated {
    [self.view setUserInteractionEnabled:YES];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Create toolbars
- (void)createMainToolbar {
    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectAddCalipersToolbar)];
    UIBarButtonItem *calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:@"Calibrate" style:UIBarButtonItemStylePlain target:self action:@selector(setupCalibration)];
    self.toggleIntervalRateButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(toggleIntervalRate)];
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithTitle:@"Image" style:UIBarButtonItemStylePlain target:self action:@selector(selectImageToolbar)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc]   initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.mainMenuItems = [NSArray arrayWithObjects:addCaliperButton, calibrateCalipersButton, self.toggleIntervalRateButton, imageButton, settingsButton, helpButton, nil];
}

- (void)createImageToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto)];
    UIBarButtonItem *adjustImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Adjust" style:UIBarButtonItemStylePlain target:self action:@selector(selectAdjustImageToolbar)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(selectMainToolbar)];
    
    self.photoMenuItems = [NSArray arrayWithObjects:takePhotoButton, selectImageButton, adjustImageButton, backToMainMenuButton, nil];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // if no camera on device, just silently disable take photo button
        [takePhotoButton setEnabled:NO];
    }
}

- (void)createAdjustImageToolbar {
    UIBarButtonItem *rotateImageRightButton = [[UIBarButtonItem alloc] initWithTitle:@"90°R" style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageRight:)];
    UIBarButtonItem *rotateImageLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"90°L" style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageLeft:)];
    UIBarButtonItem *tweakRightButton = [[UIBarButtonItem alloc] initWithTitle:@"1°R" style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageRight:)];
    UIBarButtonItem *tweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"1°L" style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageLeft:)];
    UIBarButtonItem *flipImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStylePlain target:self action:@selector(flipImage:)];
    UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(selectImageToolbar)];
    
    self.adjustImageMenuItems = [NSArray arrayWithObjects:rotateImageRightButton, rotateImageLeftButton, tweakRightButton, tweakLeftButton, flipImageButton, resetImageButton, backToImageMenuButton, nil];
    
}

- (void)createAddCalipersToolbar {
    UIBarButtonItem *horizontalButton = [[UIBarButtonItem alloc] initWithTitle:@"Horizontal" style:UIBarButtonItemStylePlain target:self action:@selector(addHorizontalCaliper)];
    UIBarButtonItem *verticalButton = [[UIBarButtonItem alloc] initWithTitle:@"Vertical" style:UIBarButtonItemStylePlain target:self action:@selector(addVerticalCaliper)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.addCalipersMenuItems = [NSArray arrayWithObjects:horizontalButton, verticalButton, cancelButton, nil];
}

- (void)createSetupCalibrationToolbar {
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setCalibration)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearCalibration)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];

    
    self.calibrateMenuItems = [NSArray arrayWithObjects:setButton, clearButton, cancelButton, nil];
}

- (void)toggleIntervalRate {
    self.horizontalCalibration.displayRate = ! self.horizontalCalibration.displayRate;
    [self.calipersView setNeedsDisplay];
}

- (void)clearCalibration {
    [self.horizontalCalibration reset];
    [self.verticalCalibration reset];
    [self.calipersView setNeedsDisplay];
}

- (void)setupCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
    }
    else {
        [self.toolbar setItems:self.calibrateMenuItems];
        [self.calipersView selectCaliperIfNoneSelected];
    }
}

- (void)setCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    if ([self.calipersView noCaliperIsSelected]) {
        UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:@"No Caliper Selected" message:@"Select a caliper by single-tapping it.  Move the caliper to a known interval.  Touch Set to enter the calibration measurement." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noSelectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlert show];
        return;
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Calibrate" message:@"Enter measurement (e.g. 500 msec)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    Caliper* c = self.calipersView.activeCaliper;
    NSString *calibrationString = @"";
    if (c != nil) {
        CaliperDirection direction = c.direction;
        if (direction == Horizontal) {
            calibrationString = self.horizontalCalibration.calibrationString;
        }
        else {
            calibrationString = self.verticalCalibration.calibrationString;
        }
    }
    
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [[alert textFieldAtIndex:0] setText:calibrationString];
    [[alert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];

    [alert show];
}

- (void)showNoCalipersAlert {
    UIAlertView *noCalipersAlert = [[UIAlertView alloc] initWithTitle:@"No Calipers To Use" message:@"Add one or more calipers first before calibration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    noCalipersAlert.alertViewStyle = UIAlertViewStyleDefault;
    [noCalipersAlert show];
}

// Select toolbars
- (void)selectImageToolbar {
    [self.toolbar setItems:self.photoMenuItems];
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)selectMainToolbar {
    [self.toolbar setItems:self.mainMenuItems];
    [self.calipersView setUserInteractionEnabled:YES];
    [self.toggleIntervalRateButton setEnabled:[self.horizontalCalibration canDisplayRate]];
}

- (void)selectAddCalipersToolbar {
    [self.toolbar setItems:self.addCalipersMenuItems];
}

- (void)selectAdjustImageToolbar {
    [self.toolbar setItems:self.adjustImageMenuItems];
}

- (void)selectCalibrateToolbar {
    [self.toolbar setItems:self.calibrateMenuItems];
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)addHorizontalCaliper {
    [self addCaliperWithDirection:Horizontal];
}

- (void)addVerticalCaliper {
    [self addCaliperWithDirection:Vertical];
}

- (void)addCaliperWithDirection:(CaliperDirection)direction {
    Caliper *caliper = [[Caliper alloc] init];
    caliper.lineWidth = self.settings.lineWidth;
    caliper.unselectedColor = self.settings.caliperColor;
    caliper.selectedColor = self.settings.highlightColor;
    caliper.direction = direction;
    if (direction == Horizontal) {
        caliper.calibration = self.horizontalCalibration;
    }
    else {
        caliper.calibration = self.verticalCalibration;
    }
    [caliper setInitialPositionInRect:self.view.bounds];
    EPSLog(@"Bounds x = %f, h = %f", self.view.bounds.origin.x, self.view.bounds.size.height);
    EPSLog(@"Frame x = %f, h = %f", self.view.frame.origin.x, self.view.frame.size.height);
   
    
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
    [self selectMainToolbar];
}

// Adjust image
static inline double radians (double degrees) {return degrees * M_PI/180;}

- (IBAction)rotateImageRight:(id)sender {
    [self rotateImage:90];
}

- (IBAction)rotateImageLeft:(id)sender {
    [self rotateImage:-90];
}

- (IBAction)tweakImageRight:(id)sender {
    [self rotateImage:1];
}

- (IBAction)tweakImageLeft:(id)sender {
    [self rotateImage:-1];
}

- (void)rotateImage:(double)degrees {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(degrees));
    }];

}

- (IBAction)resetImage:(id)sender {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        self.imageView.transform = CGAffineTransformIdentity;
    }];
}

- (IBAction)flipImage:(id)sender {
    static BOOL horizontal = YES;
    float x = 1.0;
    float y = 1.0;
    if (horizontal) {
        x = -1.0;
    } else {
        y = -1.0;
    }
    // change from horizontal to vertical with each button press
    horizontal = !horizontal;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        self.imageView.transform = CGAffineTransformScale(self.imageView.transform, x, y);
    }];
}

#pragma mark - Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *rawText = [[alertView textFieldAtIndex:0] text];
    if (rawText.length > 0) {
        float value = 0.0;
        NSString *trimmedUnits = @"";
        // commented lines can be used to test different locale behavior
        // NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"FR"];
        NSScanner *scanner = [NSScanner localizedScannerWithString:rawText];
        // scanner.locale = locale;
        [scanner scanFloat:&value];
        trimmedUnits = [[[scanner string] substringFromIndex:[scanner scanLocation]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        EPSLog(@"Entered: %@, value = %f, units = %@", rawText, value, trimmedUnits);
        if (fabsf(value) > 0.0) {
            EPSLog(@"view h = %f, view w = %f", self.view.frame.size.height, self.view.frame.size.width);
            EPSLog(@"calipersView h = %f, w = %f", self.calipersView.frame.size.height, self.calipersView.frame.size.width);
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            EPSLog(@"orientation is %ld", orientation);

            Caliper *c = self.calipersView.activeCaliper;
            if (c == nil) {
                return;
            }
            double ratio = self.view.frame.size.height/self.view.frame.size.width;
            if (c.direction == Horizontal) {
                self.horizontalCalibration.calibrationString = rawText;
                self.horizontalCalibration.units = trimmedUnits;
                self.horizontalCalibration.multiplier = value/c.valueInPoints;
                if (!self.horizontalCalibration.canDisplayRate) {
                    self.horizontalCalibration.displayRate = NO;
                }
                self.horizontalCalibration.calibratedOrientationRatio = ratio;
                self.horizontalCalibration.calibrated = YES;
            }
            else {
                self.verticalCalibration.calibrationString = rawText;
                self.verticalCalibration.units = trimmedUnits;
                self.verticalCalibration.multiplier = value/c.valueInPoints;
                self.verticalCalibration.calibratedOrientationRatio  = ratio;
                self.verticalCalibration.calibrated = YES;
            }
            [self.calipersView setNeedsDisplay];
            [self selectMainToolbar];            
        }

    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
 
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self.horizontalCalibration reset];
    [self.verticalCalibration reset];
    [self.calipersView setNeedsDisplay];
}

- (void) orientationChanged:(NSNotification *)note {
    double ratio = self.view.frame.size.height/self.view.frame.size.width;
    self.horizontalCalibration.currentOrientationRatio = ratio;
    self.verticalCalibration.currentOrientationRatio = ratio;
    EPSLog(@"Orientation changed. Ratio = %f", ratio);

}

@end
