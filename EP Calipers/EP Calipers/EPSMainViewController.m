//
//  EPSMainViewController.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "EPSMainViewController.h"
#import "Caliper.h"
#import "AngleCaliper.h"
#import "Settings.h"
#import "EPSLogging.h"
#include "Defs.h"

//:TODO: Make NO for release version
// set to yes to always show startup screen
//#define TEST_QUICK_START NO


#define ANIMATION_DURATION 0.5
#define MAX_ZOOM 10.0

#define CALIBRATE_IPAD @"Calibrate"
#define CALIBRATE_IPHONE @"Cal"
#define TOGGLE_INT_RATE_IPAD @"Interval/Rate"
#define TOGGLE_INT_RATE_IPHONE @"I/R"
#define MEAN_RATE_IPAD @"Mean Rate"
#define MEAN_RATE_IPHONE @"MRate"
#define HELP_IPAD @"Help"
#define HELP_IPHONE @"?"
#define SWITCH_IPAD @"Image"
#define SWITCH_IPHONE @"Image"
#define SWITCH_BACK @"Measure"
#define SETTINGS_IPAD @"Preferences"
#define SETTINGS_IPHONE @"Prefs"
#define BRUGADA_IPAD @"Brugada"
#define BRUGADA_IPHONE @"BrS"

// AlertView tags (arbitrary)
#define CALIBRATION_ALERTVIEW 20
#define MEAN_RR_ALERTVIEW 30
#define MEAN_RR_FOR_QTC_ALERTVIEW 43
#define NUM_PDF_PAGES_ALERTVIEW 101

#define CALIPERS_VIEW_TITLE @"EP Calipers"
#define IMAGE_VIEW_TITLE @"Image Mode"

#define IMAGE_TINT [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]

@interface EPSMainViewController ()

@end

@implementation EPSMainViewController
{
    CGPDFDocumentRef pdfRef;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    pdfRef = NULL;
    
    self.settings = [[Settings alloc] init];
    [self.settings loadPreferences];

    [self createMainToolbar];
    [self createImageToolbar];
    [self createAdjustImageToolbar];
    [self createMoreAdjustImageToolbar];
    [self createAddCalipersToolbar];
    [self createSetupCalibrationToolbar];
    [self createQTcStep1Toolbar];
    [self createQTcStep2Toolbar];
    
    [self selectMainToolbar];

    [self.imageView setContentMode:UIViewContentModeCenter];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = MAX_ZOOM;
    self.lastZoomFactor = self.scrollView.zoomScale;
    
    self.horizontalCalibration = [[Calibration alloc] init];
    self.horizontalCalibration.direction = Horizontal;

    self.verticalCalibration = [[Calibration alloc] init];
    self.verticalCalibration.direction = Vertical;
    
    self.defaultHorizontalCalChanged = NO;
    self.defaultVerticalCalChanged = NO;
    
    [self.calipersView setUserInteractionEnabled:YES];
    
    self.rrIntervalForQTc = 0.0;
    
    [self.imageView setHidden:YES];  // hide view until it is rescaled
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? SWITCH_IPAD : SWITCH_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(switchView)];
    [self.navigationItem setTitle:CALIPERS_VIEW_TITLE];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
    self.isCalipersView = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;   // nav & toolbar don't overlap view
    self.firstRun = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewBackToForeground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewBackToForeground {
    EPSLog(@"ViewBackToForeground");
    NSString *priorHorizontalDefaultCal = [NSString stringWithString:self.settings.defaultCalibration];
    NSString *priorVerticalDefaultCal = [NSString stringWithString:self.settings.defaultVerticalCalibration];
    [self.settings loadPreferences];
    self.defaultHorizontalCalChanged = ![priorHorizontalDefaultCal isEqualToString:self.settings.defaultCalibration];
    self.defaultVerticalCalChanged = ![priorVerticalDefaultCal isEqualToString:self.settings.defaultVerticalCalibration];
    [self.calipersView updateCaliperPreferences:self.settings.caliperColor selectedColor:self.settings.highlightColor lineWidth:self.settings.lineWidth roundMsec:self.settings.roundMsecRate];
    [self.calipersView setNeedsDisplay];
    
}

- (void)viewDidLayoutSubviews {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    EPSLog(@"ViewDidAppear");
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setToolbarHidden:NO];
    
    if (self.firstRun) {
        //  scale image for imageView;
        // autolayout not done in viewDidLoad
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
        CGFloat verticalSpace = statusBarHeight + navigationBarHeight + toolbarHeight;
        
        self.portraitWidth = fminf(screenHeight, screenWidth);
        self.landscapeWidth = fmaxf(screenHeight, screenWidth);
        self.portraitHeight = fmaxf(screenHeight, screenWidth) - verticalSpace;
        self.landscapeHeight = fminf(screenHeight, screenWidth) - verticalSpace;

        // if running first time and opening URL then don't load sample ECG
        if (self.launchFromURL) {
            self.launchFromURL = NO;
            if (self.launchURL != nil) {
                [self openURL:self.launchURL];
            }
        }
        else {
            self.imageView.image = [self scaleImageForImageView:self.imageView.image];
            [self.imageView setHidden:self.settings.hideStartImage];
        }
        
        [self addHorizontalCaliper];
        // NB: new calipers are not selected 
        self.firstRun = NO;
        // for testing
//        if (!TEST_QUICK_START && [[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            // app already launched
            EPSLog(@"Not first launch");
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // This is the first launch ever
            EPSLog(@"First launch");
            //TODO: Update with each version!!
            UIAlertView *quickStartAlert = [[UIAlertView alloc] initWithTitle:@"EP Calipers Quick Start" message:@"What's new: Change app settings directly from the app, using the new *Preferences* menu item.\n\nQuick Start: Use your fingers to move and position calipers or move and zoom the image.\n\nAdd calipers with the *+* menu item, single tap a caliper to select it, tap again to unselect, and double tap to delete a caliper.  After calibration the menu items that allow toggling interval and rate and calculating mean rates and QTc will be enabled.\n\nUse the *Image* button on the top left to load and adjust ECG images.\n\nTap the *Info* button at the upper right for full help."
                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [quickStartAlert show];
        }

    }
}


- (UIImage *)scaleImageForImageView:(UIImage *)image {

    CGFloat ratio;
    // determine best fit for image
    if (image.size.width > image.size.height) {
        ratio = self.portraitWidth / image.size.width;
    }
    else {
        ratio = self.landscapeHeight / image.size.height;
    }
    // use scaling rather than resizing to get sharper image
    CGImageRef imageRef = image.CGImage;
    UIImage *scaledImage = [UIImage imageWithCGImage:(CGImageRef)imageRef scale:1/ratio orientation:UIImageOrientationUp];

    return scaledImage;
}

- (void)switchView {
    self.isCalipersView = !self.isCalipersView;
    self.navigationItem.title = (self.isCalipersView ? CALIPERS_VIEW_TITLE : IMAGE_VIEW_TITLE);
    if (self.isCalipersView) {
        self.navigationController.navigationBar.barTintColor = nil;
        self.navigationController.toolbar.barTintColor = nil;
        [self.navigationItem.leftBarButtonItem setTitle:([self isRegularSizeClass] ? SWITCH_IPAD : SWITCH_IPHONE)];
        [self unfadeCaliperView];
        [self selectMainToolbar];
    }
    else {
        self.navigationController.navigationBar.barTintColor = IMAGE_TINT;
        self.navigationController.toolbar.barTintColor = IMAGE_TINT;
        [self.navigationItem.leftBarButtonItem setTitle:SWITCH_BACK];
        [self fadeCaliperView];
        [self selectImageToolbar];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Create toolbars
- (void)createMainToolbar {
    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectAddCalipersToolbar)];
    self.calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? CALIBRATE_IPAD : CALIBRATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(setupCalibration)];
    self.toggleIntervalRateButton = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? TOGGLE_INT_RATE_IPAD : TOGGLE_INT_RATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(toggleIntervalRate)];
    self.mRRButton = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? MEAN_RATE_IPAD : MEAN_RATE_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(meanRR)];
    self.qtcButton = [[UIBarButtonItem alloc] initWithTitle:@"QTc" style:UIBarButtonItemStylePlain target:self action:@selector(calculateQTc)];
    self.brugadaButton = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? BRUGADA_IPAD : BRUGADA_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(doBrugadaCalculations)];
    self.settingsButton = [[UIBarButtonItem alloc] initWithTitle:([self isRegularSizeClass] ? SETTINGS_IPAD : SETTINGS_IPHONE) style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    self.mainMenuItems = [NSArray arrayWithObjects:addCaliperButton, self.calibrateCalipersButton, self.toggleIntervalRateButton, self.mRRButton, self.qtcButton, self.brugadaButton, self.settingsButton, nil];
}

- (void)createImageToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto)];
    UIBarButtonItem *adjustImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Adjust" style:UIBarButtonItemStylePlain target:self action:@selector(selectAdjustImageToolbar)];
    // these 2 buttons only enable for multipage PDFs
    self.nextPageButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
    self.previousPageButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
    [self enablePageButtons:NO];
    self.photoMenuItems = [NSArray arrayWithObjects:takePhotoButton, selectImageButton, adjustImageButton, self.previousPageButton, self.nextPageButton, nil];
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
    UIBarButtonItem *moreAdjustButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(selectMoreAdjustImageToolbar)];
    UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(adjustImageDone)];
    
    self.adjustImageMenuItems = [NSArray arrayWithObjects:rotateImageRightButton, rotateImageLeftButton, tweakRightButton, tweakLeftButton, resetImageButton, moreAdjustButton, backToImageMenuButton, nil];
}

- (void)createMoreAdjustImageToolbar {
    UIBarButtonItem *microTweakRightButton = [[UIBarButtonItem alloc] initWithTitle:@"0.1°R" style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageRight:)];
    UIBarButtonItem *microTweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"0.1°L" style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageLeft:)];
    UIBarButtonItem *flipImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStylePlain target:self action:@selector(flipImage:)];
    UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToAdjustImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(moreAdjustImageDone)];
    self.moreAdjustImageMenuItems = [NSArray arrayWithObjects:microTweakRightButton, microTweakLeftButton, flipImageButton, resetImageButton, backToAdjustImageMenuButton, nil];
}

- (void)createAddCalipersToolbar {
    UIBarButtonItem *horizontalButton = [[UIBarButtonItem alloc] initWithTitle:@"Time" style:UIBarButtonItemStylePlain target:self action:@selector(addHorizontalCaliper)];
    UIBarButtonItem *verticalButton = [[UIBarButtonItem alloc] initWithTitle:@"Amplitude" style:UIBarButtonItemStylePlain target:self action:@selector(addVerticalCaliper)];
    UIBarButtonItem *angleButton = [[UIBarButtonItem alloc] initWithTitle:@"Angle" style:UIBarButtonItemStylePlain target:self action:@selector(addAngleCaliper)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.addCalipersMenuItems = [NSArray arrayWithObjects:horizontalButton, verticalButton, angleButton, cancelButton, nil];
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
    UIBarButtonItem *measureQTButton = [[UIBarButtonItem alloc] initWithTitle:@"Measure" style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureQT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.qtcStep2MenuItems = [NSArray arrayWithObjects:labelBarButtonItem, measureQTButton, cancelButton, nil];
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
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
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
        self.toolbarItems = self.qtcStep1MenuItems;
        self.calipersView.locked = YES;
    }
}

- (void)qtcMeasureRR {
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        UIAlertView *calculateMeanRRAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Number of Intervals" message:@"How many intervals is this caliper measuring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        calculateMeanRRAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        calculateMeanRRAlertView.tag = MEAN_RR_FOR_QTC_ALERTVIEW;
        
        [[calculateMeanRRAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setText:@"1"];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
        [calculateMeanRRAlertView show];

        self.toolbarItems = self.qtcStep2MenuItems;
    }
}

- (void)qtcMeasureQT {
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        Caliper *c = [self.calipersView activeCaliper];
        float qt = fabs([c intervalInSecs:c.intervalResult]);
        float meanRR = fabs(self.rrIntervalForQTc);  // already in secs
        NSString *result = @"Invalid Result";
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
        UIAlertView *qtcResultAlertView = [[UIAlertView alloc] initWithTitle:@"Calculated QTc" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        qtcResultAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [qtcResultAlertView show];
        [self selectMainToolbar];
    }
}

- (void)doBrugadaCalculations {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    Caliper *singleAngleCaliper = [self getLoneAngleCaliper];
    if (singleAngleCaliper != nil) {
        [self.calipersView selectCaliper:singleAngleCaliper];
        [self unselectCalipersExcept:singleAngleCaliper];
    }
    if ([self noAngleCaliperSelected]) {
        UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:@"No Angle Caliper Selected" message:@"Select an angle caliper." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noSelectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlert show];
        return;
    }
    // this had better be true
    AngleCaliper* c = (AngleCaliper*)self.calipersView.activeCaliper;
    NSAssert(c.isAngleCaliper, @"Wrong type of caliper");
    // intervalResult holds angle in radians with angle calipers
    double angleInRadians = [c intervalResult];
    double angleInDegrees = [AngleCaliper radiansToDegrees:angleInRadians];
    BOOL amplitudeCalibratedInMM = [self.verticalCalibration unitsAreMM];
    BOOL timeCalibratedInMsec = [self.horizontalCalibration unitsAreMsec];
    NSString *calibrationStatement = @"";
    NSString *riskStatement = @"Low risk of Brugada syndrome";
    if (amplitudeCalibratedInMM && timeCalibratedInMsec) {
        // calculate length of triangle base 5 mm away from apex of angle
        double pointsPerMM = 1.0 / self.verticalCalibration.multiplier;
        double pointsPerMsec = 1.0 / self.horizontalCalibration.multiplier;
        double base = [AngleCaliper calculateBaseFromHeight:5 * pointsPerMM andAngle1:c.angleBar1 andAngle2:c.angleBar2];
        double baseInMM = base / pointsPerMM;
        base /= pointsPerMsec;
        calibrationStatement = [NSString stringWithFormat:@"\n\nBase of triangle 5 mm from apex = %.1f msec.", base];
        // TODO: should base be in mm or msec?
        double riskV1 = [AngleCaliper brugadaRiskV1ForBetaAngle:angleInRadians andBase:baseInMM];
        double riskV2 = [AngleCaliper brugadaRiskV2ForBetaAngle:angleInRadians andBase:baseInMM];
        riskStatement = [NSString stringWithFormat:@"V1 risk is %f.  V2 risk is %f.", riskV1, riskV2];
    }
    else {
        calibrationStatement = @"\n\nFurther risk calculations can be made if you calibrate time calipers in milliseconds (msec) and amplitude calipers in millimeters (mm).";
    }
//    if (angleInDegrees > 58.0) {
//        riskStatement = @"Increased risk of Brugada syndrome";
//    }
    NSString *message = [NSString stringWithFormat:@"Beta angle = %.1f°%@%@", angleInDegrees, calibrationStatement, riskStatement];
    UIAlertView *brugadaResultAlert = [[UIAlertView alloc] initWithTitle:@"Brugada Syndrome Results" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [brugadaResultAlert show];
    
}

- (BOOL)noTimeCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected]  || [self.calipersView activeCaliper].direction == Vertical) || [[self.calipersView activeCaliper] isAngleCaliper];
}

- (BOOL)noAngleCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected] || ![[self.calipersView activeCaliper] isAngleCaliper]);
    
}

- (void)showNoTimeCaliperSelectedAlertView {
    UIAlertView *nothingToMeasureAlertView = [[UIAlertView alloc] initWithTitle:@"No Time Caliper Selected" message:@"Select a time caliper to measure one or more RR intervals." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
        self.toolbarItems = self.calibrateMenuItems;
        [self.calipersView selectCaliperIfNoneSelected];
        self.calipersView.locked = NO;
    }
}

- (void)setCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    if ([self.calipersView noCaliperIsSelected]) {
        UIAlertView *noSelectionAlertView = [[UIAlertView alloc] initWithTitle:@"No Caliper Selected" message:@"Select a caliper by single-tapping it.  Move the caliper to a known interval.  Touch Set to enter the calibration measurement." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        noSelectionAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlertView show];
        return;
    }
    Caliper* c = self.calipersView.activeCaliper;
    // Angle calipers don't require calibration
    if (![c requiresCalibration]) {
        UIAlertView *angleCaliperAlertView = [[UIAlertView alloc] initWithTitle:@"Angle Caliper" message:@"Angle calipers don't require calibration.  Only Time or Amplitude calipers need to be calibrated." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [angleCaliperAlertView show];
        return;
    }
    if (c.valueInPoints <= 0) {
        UIAlertView *negativeValueAlertView = [[UIAlertView alloc] initWithTitle:@"Negatively Valued Caliper" message:@"Please select a caliper with a positive value, or change this caliper to a positive value, and then repeat calibration." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [negativeValueAlertView show];
        return;
    }
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
    if ([self.horizontalCalibration.calibrationString length] < 1 || self.defaultHorizontalCalChanged) {
        self.horizontalCalibration.calibrationString = self.settings.defaultCalibration;
    }
    if ([self.verticalCalibration.calibrationString length] < 1 || self.defaultVerticalCalChanged) {
        self.verticalCalibration.calibrationString = self.settings.defaultVerticalCalibration;
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
    UIAlertView *noCalipersAlert = [[UIAlertView alloc] initWithTitle:@"No Calipers To Use" message:@"Add one or more calipers first before proceeding." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (Caliper *)getLoneAngleCaliper {
    Caliper *c = nil;
    int n = 0;
    if (self.calipersView.calipers.count > 0) {
        for (Caliper *caliper in self.calipersView.calipers) {
            if (caliper.isAngleCaliper) {
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
                [self.calipersView unselectCaliperNoNeedsDisplay:caliper];
            }
        }
        [self.calipersView setNeedsDisplay];
    }
}

// Select toolbars
- (void)selectImageToolbar {
    self.toolbarItems = self.photoMenuItems;
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)selectMainToolbar {
    self.toolbarItems  = self.mainMenuItems;
    [self.calipersView setUserInteractionEnabled:YES];
    BOOL enable = [self.horizontalCalibration canDisplayRate];
    [self.toggleIntervalRateButton setEnabled:enable];
    [self.mRRButton setEnabled:enable];
    [self.qtcButton setEnabled:enable];
    self.calipersView.locked = NO;
}

- (void)selectAddCalipersToolbar {
    self.toolbarItems = self.addCalipersMenuItems;
}

- (void)selectAdjustImageToolbar {
    self.toolbarItems = self.adjustImageMenuItems;
}

- (void)selectMoreAdjustImageToolbar {
    self.toolbarItems = self.moreAdjustImageMenuItems;
}

- (void)selectCalibrateToolbar {
    self.toolbarItems = self.calibrateMenuItems;
}

- (void)openSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        picker.allowsEditing = NO;
    }
    else{
        picker.allowsEditing = YES;
    }
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

// see http://stackoverflow.com/questions/37925583/uiimagepickercontroller-crashes-app-swift3-xcode8
- (void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        picker.allowsEditing = NO;
    }
    else{
        picker.allowsEditing = YES;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)clearPDF {
    // when opening new image or PDF, clear out any old PDF
    if (pdfRef != NULL) {
        CGPDFDocumentRelease(pdfRef);
        pdfRef = NULL;
    }
}

- (void)openURL:(NSURL *)url {
    NSString *extension = [url.pathExtension uppercaseString];
    if (![extension isEqualToString:@"PDF"]) {
        [self enablePageButtons:NO];
        self.imageView.image = [self scaleImageForImageView:[UIImage imageWithContentsOfFile:url.path]];
    }
    else {
        self.numberOfPages = 0;
        CGPDFDocumentRef tmpPDFRef = getPDFDocumentRef(url.path.UTF8String);
        if (tmpPDFRef == NULL) {
            return;
        }
        [self clearPDF];
        pdfRef = tmpPDFRef;
        self.numberOfPages = (int)CGPDFDocumentGetNumberOfPages(pdfRef);
        // always start with page number 1
        self.pageNumber = 1;
        if (self.numberOfPages > 1) {
            [self enablePageButtons:YES];
        }
        else {
            // handle single page PDF
            [self enablePageButtons:NO];
        }
        [self openPDFPage:pdfRef atPage:self.pageNumber];
    }
    [self.imageView setHidden:NO];
    [self clearCalibration];
}

- (void)enablePageButtons:(BOOL)enable {
    self.previousPageButton.enabled = self.nextPageButton.enabled = enable;
    if (enable) {
        if (self.pageNumber <= 1) {
            self.previousPageButton.enabled = NO;
        }
        if (self.pageNumber >= self.numberOfPages) {
            self.nextPageButton.enabled = NO;
        }
    }
}

- (void)gotoPreviousPage {
    self.pageNumber--;
    if (self.pageNumber < 1) {
        self.pageNumber = 1;
    }
    [self enablePageButtons:YES];
    [self openPDFPage:pdfRef atPage:self.pageNumber];
}

- (void)gotoNextPage {
    self.pageNumber++;
    if (self.pageNumber > self.numberOfPages) {
        self.pageNumber = self.numberOfPages;
    }
    [self enablePageButtons:YES];
    [self openPDFPage:pdfRef atPage:self.pageNumber];
}

- (void)openPDFPage:(CGPDFDocumentRef) documentRef atPage:(int) pageNum {
    if (documentRef == NULL) {
        return;
    }
    CGPDFPageRef page = getPDFPage(documentRef, pageNum);
    if (page == NULL) {
        return;
    }
    CGPDFPageRetain(page);
    CGRect sourceRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    // higher scale factor below makes for clearer image
    CGFloat scaleFactor = 5.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sourceRect.size.width, sourceRect.size.height), false, scaleFactor);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(currentContext, 0.0, sourceRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextDrawPDFPage(currentContext, page);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // first scale as usual, but image still too large since scaled up when created for better quality
    image = [self scaleImageForImageView:image];
    // now correct for scale factor when creating image
    image = [UIImage imageWithCGImage:(CGImageRef)image.CGImage scale:scaleFactor * image.scale orientation:UIImageOrientationUp];
    
    self.imageView.image = image;
    UIGraphicsEndImageContext();
    CGPDFPageRelease(page);
}



CGPDFDocumentRef getPDFDocumentRef(const char *filename) {
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    
    path = CFStringCreateWithCString(NULL, filename, kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease(path);
    document = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    return document;
}

CGPDFPageRef getPDFPage(CGPDFDocumentRef document, size_t pageNumber) {
    return CGPDFDocumentGetPage(document, pageNumber);
}


- (void)addHorizontalCaliper {
    [self addCaliperWithDirection:Horizontal];
}

- (void)addVerticalCaliper {
    [self addCaliperWithDirection:Vertical];
}

- (void)addAngleCaliper {
    Caliper *caliper = [[AngleCaliper alloc] init];
    [self updateCaliperSettings:caliper];
    caliper.color = caliper.unselectedColor;
    caliper.direction = Horizontal;
    //caliper.calibration = self.horizontalCalibration;
    [caliper setInitialPositionInRect:self.calipersView.bounds];
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
    [self selectMainToolbar];
}

- (void)updateCaliperSettings:(Caliper *)caliper {
    caliper.lineWidth = self.settings.lineWidth;
    caliper.unselectedColor = self.settings.caliperColor;
    caliper.selectedColor = self.settings.highlightColor;
    caliper.roundMsecRate = self.settings.roundMsecRate;
}

- (void)addCaliperWithDirection:(CaliperDirection)direction {
    Caliper *caliper = [[Caliper alloc] init];
    [self updateCaliperSettings:caliper];
    caliper.color = caliper.unselectedColor;
    caliper.direction = direction;
    if (direction == Horizontal) {
        caliper.calibration = self.horizontalCalibration;
    }
    else {
        caliper.calibration = self.verticalCalibration;
    }
    [caliper setInitialPositionInRect:self.calipersView.bounds];
    
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
    [self selectMainToolbar];
}

- (void)resetCalibration {
    // don't bother if no calibration present
    if ([self.horizontalCalibration calibrated] || [self.verticalCalibration calibrated]) {
        [self flashCalipers];
        [self.horizontalCalibration reset];
        [self.verticalCalibration reset];
    }
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

- (IBAction)microTweakImageRight:(id)sender {
    [self rotateImage:0.1];
}

- (IBAction)microTweakImageLeft:(id)sender {
    [self rotateImage:-0.1];
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

- (void)flashCalipers {
    CGFloat originalAlpha = self.calipersView.alpha;
    self.calipersView.alpha = 1.0f;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAutoreverse animations:^ {
        self.calipersView.alpha = 0.2f;
    } completion:^(BOOL finished) {
        self.calipersView.alpha = originalAlpha;
    }];
}

- (void)fadeCaliperView {
    self.calipersView.alpha = 0.5f;
}

- (void)unfadeCaliperView {
    self.calipersView.alpha = 1.0f;
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

- (void)adjustImageDone {
//    CGFloat maxImageDimension = 0.0;
//    if (self.imageView.image.size.width > self.imageView.image.size.height) {
//        maxImageDimension = self.imageView.image.size.width;
//    }
//    else {
//        maxImageDimension = self.imageView.image.size.height;
//    }
    [self selectImageToolbar];
    [self.calipersView setNeedsDisplay];
}

- (void)moreAdjustImageDone {
    [self selectAdjustImageToolbar];
}

- (BOOL)isPortraitMode {
    return self.view.frame.size.height > self.view.frame.size.width;
}

- (void)showBadValueDialog {
    UIAlertView *badValueAlertView = [[UIAlertView alloc] initWithTitle:@"Bad Input" message:@"Empty input, negative number input, or other bad input." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [badValueAlertView show];
}

#pragma mark - Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL badValue = NO;
    if (buttonIndex == 0) {
        if (alertView.tag != CALIBRATION_ALERTVIEW) {
            // calibrate cancel returns to calibrate menu, otherwise...
            [self selectMainToolbar];
        }
        return;
    }
    if (alertView.tag == CALIBRATION_ALERTVIEW) {
        NSString *rawText = [[alertView textFieldAtIndex:0] text];
        if (rawText.length > 0) {
            [self zCalibrateWithText:rawText];
        }
        else {
            badValue = YES;
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
            double intervalResult = fabs(c.intervalResult);
            double meanRR = intervalResult / divisor;
            double meanRate = [c rateResult:meanRR];
            if (alertView.tag == MEAN_RR_ALERTVIEW) {
                UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:@"Mean Interval and Rate" message:[NSString stringWithFormat:@"Mean interval = %.4g %@\nMean rate = %.4g bpm", meanRR, [c.calibration rawUnits], meanRate] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                resultAlertView.alertViewStyle = UIAlertActionStyleDefault;
                [resultAlertView show];
            }
            else {
                self.rrIntervalForQTc = [c intervalInSecs:meanRR];
            }
        }
        else {
            badValue = YES;
        }
    }
    if (badValue) {
        [self showBadValueDialog];
        if (alertView.tag != CALIBRATION_ALERTVIEW) {
            // calibrate cancel returns to calibrate menu, otherwise...
            [self selectMainToolbar];
        }
    }
}

- (void)zCalibrateWithText:(NSString *)rawText {
    if (rawText.length > 0) {
        float value = 0.0;
        NSString *trimmedUnits = @"";
        // commented lines can be used to test different locale behavior
        // NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"FR"];
        NSScanner *scanner = [NSScanner localizedScannerWithString:rawText];
        // scanner.locale = locale;
        [scanner scanFloat:&value];
        trimmedUnits = [[[scanner string] substringFromIndex:[scanner scanLocation]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // reject negative values (showBadValueDialog}
        // value = fabsf(value);
        if (value > 0.0) {
            Caliper *c = self.calipersView.activeCaliper;
            if (c == nil || c.valueInPoints <= 0) {
                return;
            }
            if (c.direction == Horizontal) {
                self.horizontalCalibration.calibrationString = rawText;
                self.horizontalCalibration.units = trimmedUnits;
                if (!self.horizontalCalibration.canDisplayRate) {
                    self.horizontalCalibration.displayRate = NO;
                }
                self.horizontalCalibration.originalZoom = self.scrollView.zoomScale;
                self.horizontalCalibration.originalCalFactor = value / c.valueInPoints;
                self.horizontalCalibration.currentZoom = self.horizontalCalibration.originalZoom;
                self.horizontalCalibration.calibrated = YES;
            }
            else {
                self.verticalCalibration.calibrationString = rawText;
                self.verticalCalibration.units = trimmedUnits;
                self.verticalCalibration.originalZoom = self.scrollView.zoomScale;
                self.verticalCalibration.originalCalFactor = value / c.valueInPoints;
                self.verticalCalibration.currentZoom = self.verticalCalibration.originalZoom;
                self.verticalCalibration.calibrated = YES;
            }
            [self.calipersView setNeedsDisplay];
            [self selectMainToolbar];
        }
        else {
            [self showBadValueDialog];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = nil;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        chosenImage = info[UIImagePickerControllerOriginalImage];
    }
    else {
        chosenImage = info[UIImagePickerControllerEditedImage];
        }
    self.imageView.image = [self scaleImageForImageView:chosenImage];
    [self.imageView setHidden:NO];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self clearCalibration];
    [self enablePageButtons:NO];
    // remove any prior PDF from memory
    [self clearPDF];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.lastZoomFactor = scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // don't move calipers, but do adjust calibration
    self.horizontalCalibration.currentZoom = scale;
    self.verticalCalibration.currentZoom = scale;
    [self.calipersView setNeedsDisplay];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.calipersView setNeedsDisplay];
}

- (BOOL)isCompactSizeClass {
    return (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

- (BOOL)isRegularSizeClass {
    return ![self isCompactSizeClass];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.toggleIntervalRateButton setTitle:[self isCompactSizeClass] ? TOGGLE_INT_RATE_IPHONE : TOGGLE_INT_RATE_IPAD];
    [self.mRRButton setTitle:[self isCompactSizeClass] ? MEAN_RATE_IPHONE : MEAN_RATE_IPAD];
    [self.calibrateCalipersButton setTitle:[self isCompactSizeClass] ? CALIBRATE_IPHONE : CALIBRATE_IPAD];
}

@end
