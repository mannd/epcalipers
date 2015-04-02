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

#define CALIBRATE_IPAD @"Calibrate"
#define CALIBRATE_IPHONE @"Cal"
#define TOGGLE_INT_RATE_IPAD @"Interval/Rate"
#define TOGGLE_INT_RATE_IPHONE @"I/R"
#define MEAN_RATE_IPAD @"meanRate"
#define MEAN_RATE_IPHONE @"mRate"
#define HELP_IPAD @"Help"
#define HELP_IPHONE @"?"

// AlertView tags (arbitrary)
#define CALIBRATION_ALERTVIEW 20
#define MEAN_RR_ALERTVIEW 30
#define MEAN_RR_FOR_QTC_ALERTVIEW 43

@interface EPSMainViewController ()

@end

@implementation EPSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    self.settings = [[Settings alloc] init];
    [self.settings loadPreferences];

    [self createMainToolbar];
    [self createImageToolbar];
    [self createAdjustImageToolbar];
    [self createAddCalipersToolbar];
    [self createSetupCalibrationToolbar];
    [self createQTcStep1Toolbar];
    [self createQTcStep2Toolbar];
    
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
    
    self.rrIntervalForQTc = 0.0;
    
    [self.imageView setHidden:self.settings.hideStartImage];

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
    UIBarButtonItem *calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:(self.isIpad ? CALIBRATE_IPAD : CALIBRATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(setupCalibration)];
    self.toggleIntervalRateButton = [[UIBarButtonItem alloc] initWithTitle:(self.isIpad ? TOGGLE_INT_RATE_IPAD : TOGGLE_INT_RATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(toggleIntervalRate)];
    self.mRRButton = [[UIBarButtonItem alloc] initWithTitle:(self.isIpad ? MEAN_RATE_IPAD : MEAN_RATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(meanRR)];
    self.qtcButton = [[UIBarButtonItem alloc] initWithTitle:@"QTc" style:UIBarButtonItemStylePlain target:self action:@selector(calculateQTc)   ];
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithTitle:@"Image" style:UIBarButtonItemStylePlain target:self action:@selector(selectImageToolbar)];
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:(self.isIpad ? HELP_IPAD : HELP_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(showHelp)];
    
    self.mainMenuItems = [NSArray arrayWithObjects:addCaliperButton, calibrateCalipersButton, self.toggleIntervalRateButton, self.mRRButton, self.qtcButton, imageButton, helpButton, nil];
}

- (void)createImageToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto)];
    UIBarButtonItem *adjustImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Adjust" style:UIBarButtonItemStylePlain target:self action:@selector(selectAdjustImageToolbar)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];
    
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
    UIBarButtonItem *backToImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectImageToolbar)];
    
    self.adjustImageMenuItems = [NSArray arrayWithObjects:rotateImageRightButton, rotateImageLeftButton, tweakRightButton, tweakLeftButton, flipImageButton, resetImageButton, backToImageMenuButton, nil];
    
}

- (void)createAddCalipersToolbar {
    UIBarButtonItem *horizontalButton = [[UIBarButtonItem alloc] initWithTitle:@"Horizontal" style:UIBarButtonItemStylePlain target:self action:@selector(addHorizontalCaliper)];
    UIBarButtonItem *verticalButton = [[UIBarButtonItem alloc] initWithTitle:@"Vertical" style:UIBarButtonItemStylePlain target:self action:@selector(addVerticalCaliper)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];
    
    self.addCalipersMenuItems = [NSArray arrayWithObjects:horizontalButton, verticalButton, cancelButton, nil];
}

- (void)createSetupCalibrationToolbar {
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setCalibration)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearCalibration)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];

    
    self.calibrateMenuItems = [NSArray arrayWithObjects:setButton, clearButton, cancelButton, nil];
}

- (void)createQTcStep1Toolbar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 32)];
    [label setText:@"RR interval(s)?"];
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *measureRRButton = [[UIBarButtonItem alloc] initWithTitle:@"Measure" style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureRR)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.qtcStep1MenuItems = [NSArray arrayWithObjects:labelBarButtonItem, measureRRButton, cancelButton, nil];
}

- (void)createQTcStep2Toolbar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 32)];
    [label setText:@"QT interval?"];
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *measureRRButton = [[UIBarButtonItem alloc] initWithTitle:@"Measure" style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureQT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.qtcStep2MenuItems = [NSArray arrayWithObjects:labelBarButtonItem, measureRRButton, cancelButton, nil];
}

- (void)showHelp {
    [self performSegueWithIdentifier:@"WebViewSegue" sender:nil];
}


- (void)toggleIntervalRate {
    self.horizontalCalibration.displayRate = ! self.horizontalCalibration.displayRate;
    [self.calipersView setNeedsDisplay];
}

- (void)meanRR {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    Caliper *singleHorizontalCaliper = [self getLoneTimeCaliper];
    if (singleHorizontalCaliper != nil) {
        [self.calipersView selectCaliper:singleHorizontalCaliper];
        [self unselectCalipersExcept:singleHorizontalCaliper];
    }
    if ([self.calipersView noCaliperIsSelected]) {
        UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:@"No Time Caliper Selected" message:@"Select a time caliper by single-tapping it.  Stretch the caliper over several intervals to get an average interval and rate." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noSelectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlert show];
        return;
    }
    Caliper* c = self.calipersView.activeCaliper;
    if (c.direction == Vertical) {
        UIAlertView *noHorizontalCaliberAlert = [[UIAlertView alloc] initWithTitle:@"No Time Caliper Selected" message:@"Select a time caliper by single-tapping it.  Stretch the caliper over several intervals to get an average interval and rate." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noHorizontalCaliberAlert.alertViewStyle = UIAlertViewStyleDefault;
        [noHorizontalCaliberAlert show];
        return;
    }
    UIAlertView *calculateMeanRRAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Number of Intervals" message:@"How many intervals is this caliper measuring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Calculate", nil];
    calculateMeanRRAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    calculateMeanRRAlertView.tag = MEAN_RR_ALERTVIEW;
    [calculateMeanRRAlertView show];
    
    [[calculateMeanRRAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[calculateMeanRRAlertView textFieldAtIndex:0] setText:@"3"];
    [[calculateMeanRRAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
}

- (void)calculateQTc {
    self.horizontalCalibration.displayRate = NO;
    Caliper *singleHorizontalCaliper = [self getLoneTimeCaliper];
    if (singleHorizontalCaliper != nil) {
        [self.calipersView selectCaliper:singleHorizontalCaliper];
        [self unselectCalipersExcept:singleHorizontalCaliper];
    }
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        self.rrIntervalForQTc = 0.0;
        [self.toolbar setItems:self.qtcStep1MenuItems];
        self.calipersView.locked = YES;
    }
}

- (void)qtcMeasureRR {
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        UIAlertView *calculateMeanRRAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Number of Intervals" message:@"How many intervals is this caliper measuring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Calculate", nil];
        calculateMeanRRAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        calculateMeanRRAlertView.tag = MEAN_RR_FOR_QTC_ALERTVIEW;
        [calculateMeanRRAlertView show];
        
        [[calculateMeanRRAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setText:@"3"];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
        
        [self.toolbar setItems:self.qtcStep2MenuItems];
    }
}

- (void)qtcMeasureQT {
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        Caliper *c = [self.calipersView activeCaliper];
        float qt = fabsf([c intervalInSecs:c.intervalResult]);
        float meanRR = fabsf(self.rrIntervalForQTc);  // already in secs
        NSString *result = @"Invalid Result";
        EPSLog(@"RR in sec = %f, QT in sec = %f", meanRR, qt);
        if (meanRR > 0) {
            float sqrtRR = sqrtf(meanRR);
            float qtc = qt/sqrtRR;
            // switch to units that calibration uses
            if (c.calibration.unitsAreMsec) {
                meanRR *= 1000;
                qt *= 1000;
                qtc *= 1000;
            }
            result = [NSString stringWithFormat:@"Mean RR = %.4g %@\nQT = %.4g %@\nQTc = %.4g %@\n(Bazett's formula)", meanRR, c.calibration.units, qt, c.calibration.units, qtc, c.calibration.units];
        }
        UIAlertView *qtcResultAlertView = [[UIAlertView alloc] initWithTitle:@"Calculated QTc" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        qtcResultAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [qtcResultAlertView show];
        [self selectMainToolbar];
    }
}

- (BOOL)noTimeCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected]  || [self.calipersView activeCaliper].direction == Vertical);
}

- (void)showNoTimeCaliperSelectedAlertView {
    UIAlertView *nothingToMeasureAlertView = [[UIAlertView alloc] initWithTitle:@"No Time Caliper Selected" message:@"Use a selected (highlighted) caliper to measure one or more RR intervals." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    nothingToMeasureAlertView.alertViewStyle = UIAlertActionStyleDefault;
    [nothingToMeasureAlertView show];
}

- (void)clearCalibration {
    [self resetCalibration];
    [self.calipersView setNeedsDisplay];
}

- (BOOL)horizontalCalipersAvailable {
    if (self.calipersView.calipers.count < 1) {
        return NO;
    }
    for (Caliper *c in self.calipersView.calipers) {
        if (c.direction == Horizontal) {
            return YES;
        }
    }
    return NO;
}

- (void)setupCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
    }
    else {
        [self.toolbar setItems:self.calibrateMenuItems];
        [self.calipersView selectCaliperIfNoneSelected];
        self.calipersView.locked = YES;
    }
}

- (void)setCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    if ([self.calipersView noCaliperIsSelected]) {
        UIAlertView *noSelectionAlertView = [[UIAlertView alloc] initWithTitle:@"No Caliper Selected" message:@"Select a caliper by single-tapping it.  Move the caliper to a known interval.  Touch Set to enter the calibration measurement." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noSelectionAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlertView show];
        return;
    }
    Caliper* c = self.calipersView.activeCaliper;
    NSString *example = @"";
    if (c!= nil && c.direction == Vertical) {
        example = @"1 mV";
    }
    else {
        example = @"500 msec";
    }
    NSString *message = [NSString stringWithFormat:@"Enter measurement (e.g. %@)", example];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Calibrate" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = CALIBRATION_ALERTVIEW;
    NSString *calibrationString = @"";
    // set initial calibration time calibration to default
    if ([self.horizontalCalibration.calibrationString length] < 1) {
        self.horizontalCalibration.calibrationString = self.settings.defaultCalibration;
    }
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
    UIAlertView *noCalipersAlert = [[UIAlertView alloc] initWithTitle:@"No Calipers To Use" message:@"Add one or more calipers first before proceeding." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    noCalipersAlert.alertViewStyle = UIAlertViewStyleDefault;
    [noCalipersAlert show];
}

- (Caliper *)getLoneTimeCaliper {
    Caliper *c = nil;
    int n = 0;
    if (self.calipersView.calipers.count > 0) {
        for (Caliper *caliper in self.calipersView.calipers) {
            if (caliper.direction == Horizontal) {
                c = caliper;
                n++;
            }
        }
    }
    if (n == 1) {
        return c;
    }
    else {
        return nil;
    }
}

- (void)unselectCalipersExcept:(Caliper *)c {
    // if only one caliper, no others can be selected
    if (self.calipersView.calipers.count > 1) {
        for (Caliper *caliper in self.calipersView.calipers) {
            if (caliper != c) {
                [self.calipersView unselectCaliper:caliper];
            }
        }
    }
}

// Select toolbars
- (void)selectImageToolbar {
    [self.toolbar setItems:self.photoMenuItems];
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)selectMainToolbar {
    [self.toolbar setItems:self.mainMenuItems];
    [self.calipersView setUserInteractionEnabled:YES];
    BOOL enable = [self.horizontalCalibration canDisplayRate];
    [self.toggleIntervalRateButton setEnabled:enable];
    [self.mRRButton setEnabled:enable];
    [self.qtcButton setEnabled:enable];
    self.calipersView.locked = NO;
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

//- (BOOL)noCalipers

- (void)addCaliperWithDirection:(CaliperDirection)direction {
    Caliper *caliper = [[Caliper alloc] init];
    caliper.lineWidth = self.settings.lineWidth;
    caliper.unselectedColor = self.settings.caliperColor;
    caliper.selectedColor = self.settings.highlightColor;
    caliper.color = caliper.unselectedColor;
    caliper.direction = direction;
    if (direction == Horizontal) {
        caliper.calibration = self.horizontalCalibration;
    }
    else {
        caliper.calibration = self.verticalCalibration;
    }
    [caliper setInitialPositionInRect:self.view.bounds];
    
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
    [self selectMainToolbar];
}

- (void)resetCalibration {
    [self.horizontalCalibration reset];
    [self.verticalCalibration reset];
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
    if (buttonIndex == 0) {
        return;
    }
    if (alertView.tag == CALIBRATION_ALERTVIEW) {
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
            // all calibrations must be positive
            value = fabsf(value);
            if (value > 0.0) {
                EPSLog(@"view h = %f, view w = %f", self.view.frame.size.height, self.view.frame.size.width);
                EPSLog(@"calipersView h = %f, w = %f", self.calipersView.frame.size.height, self.calipersView.frame.size.width);
                
                Caliper *c = self.calipersView.activeCaliper;
                if (c == nil || c.valueInPoints <= 0) {
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
    else if (alertView.tag == MEAN_RR_ALERTVIEW || alertView.tag == MEAN_RR_FOR_QTC_ALERTVIEW) {
        NSString *rawText = [[alertView textFieldAtIndex:0] text];
        int divisor = [rawText intValue];
        if (divisor > 0) {
            Caliper *c = self.calipersView.activeCaliper;
            if (c == nil) {
                return;
            }
            double intervalResult = fabsf(c.intervalResult);
            double meanRR = intervalResult / divisor;
            EPSLog(@"Average RR = %.4g %@", meanRR, [c.calibration rawUnits]);
            double meanRate = [c rateResult:meanRR];
            EPSLog(@"Average rate = %.4g bpm", meanRate);
            if (alertView.tag == MEAN_RR_ALERTVIEW) {
                UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:@"Mean Interval and Rate" message:[NSString stringWithFormat:@"Mean interval = %.4g %@\nMean rate = %.4g bpm", meanRR, [c.calibration rawUnits], meanRate] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                resultAlertView.alertViewStyle = UIAlertActionStyleDefault;
                [resultAlertView show];
            }
            else {
                self.rrIntervalForQTc = [c intervalInSecs:meanRR];
            }
            
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self.imageView setHidden:NO];
 
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self clearCalibration];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self clearCalibration];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    double ratio = size.height/size.width;
    self.horizontalCalibration.currentOrientationRatio = ratio;
    self.verticalCalibration.currentOrientationRatio = ratio;
    [self.calipersView shiftCalipers:ratio forNewHeight:size.height];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
}


@end
