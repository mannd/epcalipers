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
#import "About.h"
#import "CaliperFactory.h"
#import "MiniQTcResult.h"
#include "Defs.h"

//:TODO: Make NO for release version
// set to yes to always show startup screen
//#define TEST_QUICK_START NO

#define ANIMATION_DURATION 0.5
#define MAX_ZOOM 10.0
#define MOVEMENT 1.0f
#define MICRO_MOVEMENT 0.1f

#define CALIBRATE_IPAD L(@"Calibrate")
#define CALIBRATE_IPHONE L(@"Cal")
#define TOGGLE_INT_RATE_IPAD L(@"Interval/Rate")
#define TOGGLE_INT_RATE_IPHONE L(@"I/R")
#define MEAN_RATE_IPAD L(@"Mean Rate")
#define MEAN_RATE_IPHONE L(@"MRate")
#define HELP L(@"Help")
#define CANCEL L(@"Cancel")
#define ABOUT L(@"About")
#define BACK L(@"Back")
#define SET L(@"Set")
#define CLEAR L(@"Clear")
#define MORE L(@"More")
#define OK L(@"OK")
#define DONE L(@"Done")

#define SWITCH_IPAD L(@"Image")
#define SWITCH_IPHONE L(@"Image")
#define SWITCH_BACK L(@"Measure")
#define TWEAK_IPAD L(@"Tweak-iPad")
#define TWEAK_IPHONE L(@"Tweak-iPhone")
#define LOCK_IPAD L(@"Lock-iPad")
#define LOCK_IPHONE L(@"Lock-iPhone")
#define UNLOCK_IPAD L(@"Unlock-iPad")
#define UNLOCK_IPHONE L(@"Unlock-iPhone")
//#define BRUGADA_IPAD @"Brugada"
//#define BRUGADA_IPHONE @"BrS"
#define LEFT_ARROW @"⇦"
#define RIGHT_ARROW @"⇨"
#define MICRO_LEFT_ARROW @"←"
#define MICRO_RIGHT_ARROW @"→"
#define UP_ARROW @"⇧"
#define DOWN_ARROW @"⇩"
#define MICRO_UP_ARROW @"↑"
#define MICRO_DOWN_ARROW @"↓"

#define VERY_SMALL_FONT 10
#define SMALL_FONT 12
#define INTERMEDIATE_FONT 14
#define REGULAR_FONT 17 // This is updated when menus created.

// AlertView tags (arbitrary)
#define CALIBRATION_ALERTVIEW 20
#define MEAN_RR_ALERTVIEW 30
#define MEAN_RR_FOR_QTC_ALERTVIEW 43
#define NUM_PDF_PAGES_ALERTVIEW 101
#define LAUNCHED_FROM_URL_ALERTVIEW 102
#define QTC_RESULT_ALERTVIEW 104

#define CALIPERS_VIEW_TITLE L(@"EP Calipers")
#define IMAGE_VIEW_TITLE L(@"Image Mode")

#define IMAGE_TINT [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]



@interface EPSMainViewController ()

@property (strong, atomic) UIFont *verySmallFont;
@property (strong, atomic) NSDictionary *verySmallFontAttributes;
@property (strong, atomic) UIFont *smallFont;
@property (strong, atomic) NSDictionary *smallFontAttributes;
@property (strong, atomic) UIFont *intermediateFont;
@property (strong, atomic) NSDictionary *intermediateFontAttributes;
@property (strong, atomic) UIFont *regularFont;
@property (strong, atomic) NSDictionary *regularFontAttributes;

@end

@implementation EPSMainViewController
{
    CGPDFDocumentRef pdfRef;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"viewDidLoad");
    
    pdfRef = NULL;
    
    self.settings = [[Settings alloc] init];
    [self.settings loadPreferences];
    
    // fonts
    NSUInteger verySmallFontSize = VERY_SMALL_FONT;
    self.verySmallFont = [UIFont boldSystemFontOfSize:verySmallFontSize];
    self.verySmallFontAttributes = @{NSFontAttributeName: self.verySmallFont};
    NSUInteger smallFontSize = SMALL_FONT;
    self.smallFont = [UIFont boldSystemFontOfSize:smallFontSize];
    self.smallFontAttributes = @{NSFontAttributeName: self.smallFont};
    NSUInteger intermediateFontSize = INTERMEDIATE_FONT;
    self.intermediateFont = [UIFont boldSystemFontOfSize:intermediateFontSize];
    self.intermediateFontAttributes = @{NSFontAttributeName: self.intermediateFont};
    NSUInteger regularFontSize = REGULAR_FONT;
    self.regularFont = [UIFont boldSystemFontOfSize:regularFontSize];
    self.regularFontAttributes = @{NSFontAttributeName: self.regularFont};
    
    self.isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    [self createToolbars];

    [self.imageView setContentMode:UIViewContentModeCenter];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = MAX_ZOOM;
    
    self.horizontalCalibration = [[Calibration alloc] init];
    self.horizontalCalibration.direction = Horizontal;

    self.verticalCalibration = [[Calibration alloc] init];
    self.verticalCalibration.direction = Vertical;
    
    self.defaultHorizontalCalChanged = NO;
    self.defaultVerticalCalChanged = NO;
    
    [self.calipersView setUserInteractionEnabled:YES];
    
    self.calipersView.delegate = self;
        
    self.rrIntervalForQTc = 0.0;
    self.inQtc = NO;
    
    
    [self.imageView setHidden:YES];  // hide view until it is rescaled
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSecondaryMenu)];
    self.navigationItem.rightBarButtonItem = btn;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:SWITCH_IPAD compactSize:SWITCH_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(switchView)];
    [self.navigationItem setTitle:CALIPERS_VIEW_TITLE];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
    self.isCalipersView = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;   // nav & toolbar don't overlap view
    self.firstRun = YES;
    
    self.wasLaunchedFromUrl = NO;
    
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    EPSLog(@"ViewDidAppear");
    
    EPSLog(@"Language code using preferredLanguages = %@", [[NSLocale preferredLanguages] firstObject]);
    EPSLog(@"Language code using localizedStrings = %@", [self applicationLanguage]);
    
    
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
        
        // if running first time and opening URL then overwrite old image
        if (self.launchFromURL) {
            self.launchFromURL = NO;
            if (self.launchURL != nil) {
                [self openURL:self.launchURL];
            }
        }
        else {
            self.imageView.image = [self scaleImageForImageView:self.imageView.image];
        }
        
        if (self.wasLaunchedFromUrl) {
	  UIAlertView *launchedFromUrlAlert = [[UIAlertView alloc] initWithTitle:L(@"Multipage PDF") message:L(@"App has been restored from background, so multipage PDF will only show current page.  You will need to reopen PDF with the app to view all pages.") delegate:self cancelButtonTitle:OK otherButtonTitles:nil];
            launchedFromUrlAlert.tag = LAUNCHED_FROM_URL_ALERTVIEW;
            [launchedFromUrlAlert show];
            // only show this warning once
            self.launchURL = nil;
            self.numberOfPages = 0;
            self.wasLaunchedFromUrl = NO;
        }
        
        [self.imageView setHidden:NO];
        // When starting add a caliper if one isn't there already
        if ([self.calipersView count] == 0) {
            [self addHorizontalCaliper];
        }
        
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
            // NOTE: for now we will eliminate this dialog, though keep the first launch startup code,
            // otherwise app breaks.
            
            //TODO: Update with each version!!
//            UIAlertView *quickStartAlert = [[UIAlertView alloc] initWithTitle:L(@"EP Calipers Quick Start") message:@"What's new: Color calipers individually.  Use the *Tweak* menu to micro-move caliper components.  App maintains state when terminated by iOS and restored.  Bug fixes.  See Help for more details.\n\nQuick Start: Use your fingers to move and position calipers or move and zoom the image.\n\nAdd calipers with the *+* menu item, single tap a caliper to select it, tap again to unselect, and double tap to delete a caliper.  After calibration the menu items that allow toggling interval and rate and calculating mean rates and QTc will be enabled.\n\nUse the *Image* button on the top left to load and adjust ECG images.\n\nTap the action button at the upper right for full help."
//                                                                     delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
//            [quickStartAlert show];
            
        }
        
        [self selectMainToolbar];

    }
}

- (NSString *)applicationLanguage {
    return L(@"lang");
}

- (BOOL)usingRussian {
    return [[self applicationLanguage] isEqualToString:@"ru"];
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
        [self.navigationItem.leftBarButtonItem setTitle:[self selectSize:SWITCH_IPAD compactSize:SWITCH_IPHONE]];
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

// Help menu, etc.
- (void)showSecondaryMenu {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* preferencesAction = [UIAlertAction actionWithTitle:L(@"Preferences") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {[self openSettings];}];
    [actionSheet addAction:preferencesAction];
    UIAlertAction* helpAction = [UIAlertAction actionWithTitle:HELP style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {[self performSegueWithIdentifier:@"WebViewSegue" sender:self];}];
    [actionSheet addAction:helpAction];
    UIAlertAction* aboutAction = [UIAlertAction actionWithTitle:ABOUT style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {[About show];}];
    [actionSheet addAction:aboutAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel
                                                         handler:nil];
    [actionSheet addAction:cancelAction];
    
    actionSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// Create toolbars
- (void)createToolbars {
    [self createMainToolbar];
    [self createImageToolbar];
    [self createAdjustImageToolbar];
    [self createMoreAdjustImageToolbar];
    [self createAddCalipersToolbar];
    [self createSetupCalibrationToolbar];
    [self createQTcStep1Toolbar];
    [self createQTcStep2Toolbar];
    [self createMoreToolbar];
    [self createColorToolbar];
    [self createTweakToolbar];
    [self createMovementToolbar];
    [self fixupMenus:[self isCompactSizeClass]];
}

- (NSString *)selectSize:(NSString *)regularSize compactSize:(NSString *)compactSize {
    return [self isRegularSizeClass] ? regularSize : compactSize;
}

- (void)createMainToolbar {
    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectAddCalipersToolbar)];
    self.calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:CALIBRATE_IPAD compactSize:CALIBRATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(setupCalibration)];
    self.toggleIntervalRateButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:TOGGLE_INT_RATE_IPAD compactSize:TOGGLE_INT_RATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(toggleIntervalRate)];
    self.mRRButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:MEAN_RATE_IPAD compactSize:MEAN_RATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(meanRR)];
    self.qtcButton = [[UIBarButtonItem alloc] initWithTitle:@"QTc" style:UIBarButtonItemStylePlain target:self action:@selector(calculateQTc)];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:MORE style:UIBarButtonItemStylePlain target:self action:@selector(selectMoreToolbar)];
    self.mainMenuItems = [NSArray arrayWithObjects:addCaliperButton,
                          self.calibrateCalipersButton,
                          self.toggleIntervalRateButton,
                          self.mRRButton,
                          self.qtcButton,
                          /* self.brugadaButton ? */
                          moreButton, nil];
}

- (void)createImageToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Select") style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto)];
    UIBarButtonItem *adjustImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Adjust") style:UIBarButtonItemStylePlain target:self action:@selector(selectAdjustImageToolbar)];
    UIBarButtonItem *clearImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Sample") style:UIBarButtonItemStylePlain target:self action:@selector(loadDefaultImage)];
    // these 2 buttons only enable for multipage PDFs
    self.nextPageButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
    self.previousPageButton = [[UIBarButtonItem alloc] initWithTitle:LEFT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
    [self enablePageButtons:NO];
    self.photoMenuItems = [NSArray arrayWithObjects:takePhotoButton, selectImageButton, adjustImageButton, clearImageButton, self.previousPageButton, self.nextPageButton, nil];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // if no camera on device, just silently disable take photo button
        [takePhotoButton setEnabled:NO];
    }
}

- (void)createAdjustImageToolbar {
  UIBarButtonItem *rotateImageRightButton = [[UIBarButtonItem alloc] initWithTitle:L(@"90°R") style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageRight:)];
  UIBarButtonItem *rotateImageLeftButton = [[UIBarButtonItem alloc] initWithTitle:L(@"90°L") style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageLeft:)];
  UIBarButtonItem *tweakRightButton = [[UIBarButtonItem alloc] initWithTitle:L(@"1°R") style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageRight:)];
  UIBarButtonItem *tweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:L(@"1°L") style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageLeft:)];
    UIBarButtonItem *moreAdjustButton = [[UIBarButtonItem alloc] initWithTitle:MORE style:UIBarButtonItemStylePlain target:self action:@selector(selectMoreAdjustImageToolbar)];
    UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Reset") style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(adjustImageDone)];
    
    self.adjustImageMenuItems = [NSArray arrayWithObjects:rotateImageRightButton, rotateImageLeftButton, tweakRightButton, tweakLeftButton, resetImageButton, moreAdjustButton, backToImageMenuButton, nil];
}

- (void)createMoreAdjustImageToolbar {
  UIBarButtonItem *microTweakRightButton = [[UIBarButtonItem alloc] initWithTitle:L(@"0.1°R") style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageRight:)];
  UIBarButtonItem *microTweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:L(@"0.1°L") style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageLeft:)];
  UIBarButtonItem *flipImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Flip") style:UIBarButtonItemStylePlain target:self action:@selector(flipImage:)];
  UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Reset") style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToAdjustImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(moreAdjustImageDone)];
    self.moreAdjustImageMenuItems = [NSArray arrayWithObjects:microTweakRightButton, microTweakLeftButton, flipImageButton, resetImageButton, backToAdjustImageMenuButton, nil];
}

- (void)createAddCalipersToolbar {
    UIBarButtonItem *horizontalButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Time") style:UIBarButtonItemStylePlain target:self action:@selector(addHorizontalCaliper)];
    UIBarButtonItem *verticalButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Amplitude") style:UIBarButtonItemStylePlain target:self action:@selector(addVerticalCaliper)];
    UIBarButtonItem *angleButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Angle") style:UIBarButtonItemStylePlain target:self action:@selector(addAngleCaliper)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.addCalipersMenuItems = [NSArray arrayWithObjects:horizontalButton, verticalButton, angleButton, cancelButton, nil];
}

- (void)createSetupCalibrationToolbar {
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:SET style:UIBarButtonItemStylePlain target:self action:@selector(setCalibration)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:CLEAR style:UIBarButtonItemStylePlain target:self action:@selector(clearCalibration)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];

    
    self.calibrateMenuItems = [NSArray arrayWithObjects:setButton, clearButton, cancelButton, nil];
}

- (void)createQTcStep1Toolbar {
    UILabel *label = [[UILabel alloc] init];
    [label setText:L(@"RR interval(s)?")];
    [label sizeToFit];
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *measureRRButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Measure") style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureRR)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.qtcStep1MenuItems = [NSArray arrayWithObjects:labelBarButtonItem, measureRRButton, cancelButton, nil];
}

- (void)createQTcStep2Toolbar {
    UILabel *label = [[UILabel alloc] init];
    [label setText:L(@"QT interval?")];
    [label sizeToFit];
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *measureQTButton = [[UIBarButtonItem alloc] initWithTitle:L(@"Measure") style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureQT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];
    
    self.qtcStep2MenuItems = [NSArray arrayWithObjects:labelBarButtonItem, measureQTButton, cancelButton, nil];
}

- (void)createMoreToolbar {
    UIBarButtonItem *colorBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L(@"Color") style:UIBarButtonItemStylePlain target:self action:@selector(selectColorToolbar)];
    UIBarButtonItem *tweakBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:TWEAK_IPAD compactSize:TWEAK_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(selectTweakToolbar)];
    UIBarButtonItem *marchingBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L(@"March") style:UIBarButtonItemStylePlain target:self action:@selector(toggleMarchingCalipers)];
    self.lockImageButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:LOCK_IPAD compactSize:LOCK_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(lockImage)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];
    self.moreMenuItems = [NSArray arrayWithObjects:colorBarButtonItem, tweakBarButtonItem, marchingBarButtonItem, self.lockImageButton, cancelButton, nil];
}

- (void)createColorToolbar {
    UILabel *label = [[UILabel alloc] init];
    [label setText:L(@"Long press caliper")];
    if ([self usingRussian]) {
        [label setFont:self.intermediateFont];
    }
    [label sizeToFit];

    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];
    self.colorMenuItems = [NSArray arrayWithObjects:labelBarButtonItem, cancelButton, nil];
}

- (void)createTweakToolbar {
    UILabel *label = [UILabel new];
    [label setText:L(@"Long press caliper component")];
    if ([self usingRussian]) {
        [label setFont:self.smallFont];
    }
    [label sizeToFit];
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];
    self.tweakMenuItems = [NSArray arrayWithObjects:labelBarButtonItem, cancelButton, nil];
}

- (void)createMovementToolbar {
    
    self.componentLabel = [UILabel new];
    [self.componentLabel setText:@"Right"];
    [self.componentLabel sizeToFit];
    
    // SNEAKY:  We adjust regular size font here
    self.regularFont = self.componentLabel.font;
    self.regularFontAttributes = @{NSFontAttributeName:self.regularFont};
    
    EPSLog(@"Regular font = %f", self.regularFont.pointSize);
    
    self.componentLabelButton = [[UIBarButtonItem alloc] initWithCustomView:self.componentLabel];
    self.leftButton = [[UIBarButtonItem alloc] initWithTitle:LEFT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveLeft)];
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveRight)];
    
    self.upButton = [[UIBarButtonItem alloc] initWithTitle:UP_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveUp)];
    self.downButton = [[UIBarButtonItem alloc] initWithTitle:DOWN_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveDown)];
    self.microLeftButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_LEFT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveLeft)];
    self.microRightButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_RIGHT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveRight)];
    self.microUpButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_UP_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveUp)];
    self.microDownButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_DOWN_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveDown)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTweaking)];
    self.movementMenuItems = [NSArray arrayWithObjects:self.componentLabelButton, self.leftButton,
                              self.upButton, self.rightButton, self.downButton,
                              self.microLeftButton, self.microUpButton,
                              self.microRightButton,
                              self.microDownButton, doneButton, nil];
    
}

- (void)shrinkButtonFontSize:(NSArray *)barButtonItems {
    [self changeButtonFontSize:barButtonItems attributes:self.smallFontAttributes];
}

- (void)slightlyShrinkButtonFontSize:(NSArray *)barButtonItems {
    [self changeButtonFontSize:barButtonItems attributes:self.intermediateFontAttributes];
}

- (void)greatlyShrinkButtonFontSize:(NSArray *)barButtoneItems {
    [self changeButtonFontSize:barButtoneItems attributes:self.verySmallFontAttributes];
}

- (void)expandButtonFontSize:(NSArray *)barButtonItems {
    [self changeButtonFontSize:barButtonItems attributes:self.regularFontAttributes];
}

- (void)changeButtonFontSize:(NSArray *)barButtonItems attributes:(NSDictionary *)attributes {
    for (UIBarButtonItem* button in barButtonItems) {
        [button setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [button setTitleTextAttributes:attributes forState:UIControlStateDisabled];
        [button setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    }
}

- (void)shrinkMenus {
    [self.componentLabel setFont:self.smallFont];
    [self shrinkButtonFontSize:self.movementMenuItems];
    [self shrinkButtonFontSize:self.photoMenuItems];
    [self shrinkButtonFontSize:self.adjustImageMenuItems];
    if ([self usingRussian]) {
        [self greatlyShrinkButtonFontSize:self.movementMenuItems];
        [self greatlyShrinkButtonFontSize:self.photoMenuItems];
        [self greatlyShrinkButtonFontSize:self.adjustImageMenuItems];
        [self slightlyShrinkButtonFontSize:self.moreAdjustImageMenuItems];
        [self slightlyShrinkButtonFontSize:self.moreMenuItems];
        [self slightlyShrinkButtonFontSize:self.colorMenuItems];
        [self slightlyShrinkButtonFontSize:self.tweakMenuItems];
        [self slightlyShrinkButtonFontSize:self.addCalipersMenuItems];
    }
}

- (void)enlargeMenus {
    [self.componentLabel setFont:self.regularFont];
    [self expandButtonFontSize:self.movementMenuItems];
    [self expandButtonFontSize:self.photoMenuItems];
    [self expandButtonFontSize:self.adjustImageMenuItems];
    if ([self usingRussian]) {
        [self expandButtonFontSize:self.moreMenuItems];
        [self expandButtonFontSize:self.moreAdjustImageMenuItems];
        [self expandButtonFontSize:self.colorMenuItems];
        [self expandButtonFontSize:self.tweakMenuItems];
        [self expandButtonFontSize:self.addCalipersMenuItems];
    }
}

- (void)fixupMenus:(BOOL)shrink {
  if (shrink) {
    [self shrinkMenus];
  }
  else {
    [self enlargeMenus];
  }
}

- (void)toggleMarchingCalipers{
    [self.calipersView toggleShowMarchingCaliper];
    [self.calipersView setNeedsDisplay];
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
    
// Alternate way to do this using UIAlertController, however, too many UIAlertViews and not worth changing.
// We'll keep this commented code here as a reminder in case Apple ever really gets rid of UIAlertView for good.
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:L(@"Enter Number of Intervals") message:L(@"How many intervals is this caliper measuring?") preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:L(@"Calculate") style:UIAlertActionStyleDefault handler:nil]];
//    [alertController addAction:[UIAlertAction actionWithTitle:L(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField* inputTextField){
//        [inputTextField setKeyboardType:UIKeyboardTypeNumberPad];
//        [inputTextField setText:@"3"];
//        [inputTextField setClearButtonMode:UITextFieldViewModeAlways];}];
//    [self presentViewController:alertController animated:YES completion:nil];
   
    UIAlertView *calculateMeanRRAlertView = [[UIAlertView alloc] initWithTitle:L(@"Enter Number of Intervals") message:L(@"How many intervals is this caliper measuring?") delegate:self cancelButtonTitle:CANCEL otherButtonTitles:L(@"Calculate"), nil];
    calculateMeanRRAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    calculateMeanRRAlertView.tag = MEAN_RR_ALERTVIEW;
    [calculateMeanRRAlertView show];
    
    [[calculateMeanRRAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[calculateMeanRRAlertView textFieldAtIndex:0] setText:L(@"3")];
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
      UIAlertView *calculateMeanRRAlertView = [[UIAlertView alloc] initWithTitle:L(@"Enter Number of Intervals") message:L(@"How many intervals is this caliper measuring?") delegate:self cancelButtonTitle:CANCEL otherButtonTitles:L(@"Continue"), nil];
        calculateMeanRRAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        calculateMeanRRAlertView.tag = MEAN_RR_FOR_QTC_ALERTVIEW;
        
        [[calculateMeanRRAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setText:@"1"];
        [[calculateMeanRRAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
        [calculateMeanRRAlertView show];

        self.toolbarItems = self.qtcStep2MenuItems;
        self.calipersView.allowTweakPosition = self.settings.allowTweakDuringQtc;
        self.inQtc = YES;
        
    }
}

- (void)qtcMeasureQT {
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        EPSLog(@"QTc formula is %lu", (unsigned long)self.settings.qtcFormula);
        Caliper *c = [self.calipersView activeCaliper];
        float qt = fabs([c intervalInSecs:c.intervalResult]);
        float meanRR = fabs(self.rrIntervalForQTc);  // already in secs
        MiniQTcResult *qtcResult = [[MiniQTcResult alloc] init];
        NSString *result = [qtcResult calculateFromQtInSec:qt rrInSec:meanRR formula:self.settings.qtcFormula convertToMsec:c.calibration.unitsAreMsec units:c.calibration.units];
        UIAlertView *qtcResultAlertView = [[UIAlertView alloc] initWithTitle:L(@"Calculated QTc") message:result delegate:self cancelButtonTitle:DONE otherButtonTitles: L(@"Repeat QT"), nil];
        qtcResultAlertView.tag = QTC_RESULT_ALERTVIEW;
        qtcResultAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [qtcResultAlertView show];
        //[self selectMainToolbar];
    }
}

// this is not used in current version, and in next version will be modified to provide
// dialog with beta angle, base length, and probability of Brugada pattern ECG
// TODO: If this is used, strings need to be localized
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
      UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:L(@"No Angle Caliper Selected") message:L(@"Select an angle caliper.") delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
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
    UIAlertView *brugadaResultAlert = [[UIAlertView alloc] initWithTitle:@"Brugada Syndrome Results" message:message delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
    [brugadaResultAlert show];
    
}

- (BOOL)noTimeCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected]  || [self.calipersView activeCaliper].direction == Vertical) || [[self.calipersView activeCaliper] isAngleCaliper];
}

- (BOOL)noAngleCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected] || ![[self.calipersView activeCaliper] isAngleCaliper]);
    
}

- (void)showNoTimeCaliperSelectedAlertView {
  UIAlertView *nothingToMeasureAlertView = [[UIAlertView alloc] initWithTitle:L(@"No Time Caliper Selected") message:L(@"Select a time caliper to measure one or more RR intervals.") delegate:nil cancelButtonTitle:OK otherButtonTitles: nil];
    nothingToMeasureAlertView.alertViewStyle = UIAlertActionStyleDefault;
    [nothingToMeasureAlertView show];
}

- (void)clearCalibration {
    [self resetCalibration];
    [self.calipersView setNeedsDisplay];
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
        UIAlertView *noSelectionAlertView = [[UIAlertView alloc] initWithTitle:L(@"No Caliper Selected") message:L(@"Select a caliper by single-tapping it.  Move the caliper to a known interval.  Touch Set to enter the calibration measurement.") delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
        noSelectionAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [noSelectionAlertView show];
        return;
    }
    Caliper* c = self.calipersView.activeCaliper;
    // Angle calipers don't require calibration
    if (![c requiresCalibration]) {
      UIAlertView *angleCaliperAlertView = [[UIAlertView alloc] initWithTitle:L(@"Angle Caliper") message:L(@"Angle calipers don't require calibration.  Only time or amplitude calipers need to be calibrated.\n\nIf you want to use an angle caliper as a Brugadometer, you must first calibrate time and amplitude calipers.") delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
        [angleCaliperAlertView show];
        return;
    }
    if (c.valueInPoints <= 0) {
      UIAlertView *negativeValueAlertView = [[UIAlertView alloc] initWithTitle:L(@"Negatively Valued Caliper") message:L(@"Please select a caliper with a positive value, or change this caliper to a positive value, and then repeat calibration.") delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
        [negativeValueAlertView show];
        return;
    }
    NSString *example = @"";
    if (c!= nil && c.direction == Vertical) {
        example = L(@"1 mV");
    }
    else {
        example = L(@"500 msec");
    }
    NSString *message = [NSString stringWithFormat:L(@"Enter measurement (e.g. %@)"), example];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:L(@"Calibrate") message:message delegate:self cancelButtonTitle:CANCEL otherButtonTitles:SET, nil];
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
  UIAlertView *noCalipersAlert = [[UIAlertView alloc] initWithTitle:L(@"No Calipers To Use") message:L(@"Add one or more calipers first before proceeding.") delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
    noCalipersAlert.alertViewStyle = UIAlertViewStyleDefault;
    [noCalipersAlert show];
}

- (Caliper *)getLoneTimeCaliper {
    Caliper *c = nil;
    int n = 0;
    if (self.calipersView.calipers.count > 0) {
        for (Caliper *caliper in self.calipersView.calipers) {
            if (caliper.isTimeCaliper) {
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

- (void)doneTweaking {
    if (self.inQtc && self.settings.allowTweakDuringQtc) {
        self.toolbarItems = self.qtcStep2MenuItems;
    }
    else {
        [self selectMainToolbar];
    }
}

- (void)selectMainToolbar {
    self.toolbarItems  = self.mainMenuItems;
    [self.calipersView setUserInteractionEnabled:YES];
    BOOL enable = [self.horizontalCalibration canDisplayRate];
    [self.toggleIntervalRateButton setEnabled:enable];
    [self.mRRButton setEnabled:enable];
    [self.qtcButton setEnabled:enable];
    self.calipersView.locked = NO;
    self.calipersView.allowColorChange = NO;
    self.calipersView.allowTweakPosition = NO;
    self.inQtc = NO;
    self.chosenCaliper = nil;
    self.chosenCaliperComponent = None;
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

- (void)selectMoreToolbar {
    self.toolbarItems = self.moreMenuItems;
}

- (void)selectColorToolbar {
    self.toolbarItems = self.colorMenuItems;
    self.calipersView.allowColorChange = YES;
}

- (void)selectTweakToolbar {
    self.toolbarItems = self.tweakMenuItems;
    self.calipersView.allowTweakPosition = YES;
}

- (void)selectMovementToolbar {
    self.toolbarItems = self.movementMenuItems;
}

- (void)openSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (self.isIpad) {
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
    if (self.isIpad) {
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
    [self.scrollView setZoomScale:1.0f];
    [self clearCalibration];
}

- (void)loadDefaultImage {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sampleECG" withExtension:@"jpg"];
    [self openURL:url];
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
    AngleCaliper *caliper = (AngleCaliper *)[CaliperFactory createCaliper:Angle];
    [self updateCaliperSettings:caliper];
    caliper.color = caliper.unselectedColor;
    caliper.direction = Horizontal;
    caliper.calibration = self.horizontalCalibration;
    caliper.verticalCalibration = self.verticalCalibration;
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
    Caliper *caliper = [CaliperFactory createCaliper:Interval];
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
    [UIView animateWithDuration:0.5 animations:^{
        self.calipersView.alpha = 0.5f;}];
}

- (void)unfadeCaliperView {
    [UIView animateWithDuration:0.5 animations:^{
        self.calipersView.alpha = 1.0f;}];
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
  UIAlertView *badValueAlertView = [[UIAlertView alloc] initWithTitle:L(@"Bad Input") message:L(@"Empty input, negative number input, or other bad input.") delegate:nil cancelButtonTitle:OK otherButtonTitles: nil];
    [badValueAlertView show];
}

#pragma mark - Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL badValue = NO;
    if (alertView.tag == QTC_RESULT_ALERTVIEW) {
        if (buttonIndex == 0) {
            [self selectMainToolbar];
        }
        // Repeat QT measurement button
        else if (buttonIndex == 1) {
            self.toolbarItems = self.qtcStep2MenuItems;
        }
        return;
    }
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
            [self calibrateWithText:rawText];
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
                UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:L(@"Mean Interval and Rate") message:[NSString localizedStringWithFormat:L(@"Mean interval = %.4g %@\nMean rate = %.4g bpm"), meanRR, [c.calibration rawUnits], meanRate] delegate:nil cancelButtonTitle:OK otherButtonTitles: nil];
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

- (void)calibrateWithText:(NSString *)rawText {
    if (rawText.length > 0) {
        float value = 0.0;
        NSString *trimmedUnits = @"";
        // commented lines can be used to test different locale behavior
        //NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"FR"];
        NSScanner *scanner = [NSScanner localizedScannerWithString:rawText];
        //scanner.locale = locale;
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

// Note this generates warning: [Generic] Creating an image format with an unknown type is an error
// However, it still works, and no solution found with ObjC (though maybe works in Swift 3).
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = nil;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (self.isIpad) {
        chosenImage = info[UIImagePickerControllerOriginalImage];
    }
    else {
        chosenImage = info[UIImagePickerControllerEditedImage];
        }
    self.imageView.image = [self scaleImageForImageView:chosenImage];
    // reset zoom for new image
    self.scrollView.zoomScale = 1.0;
    [self.imageView setHidden:NO];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self clearCalibration];
    [self enablePageButtons:NO];
    // remove any prior PDF from memory
    [self clearPDF];
    self.launchURL = nil;
    self.numberOfPages = 0;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
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
    return (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

- (BOOL)isRegularSizeClass {
    return ![self isCompactSizeClass];
}

// TODO: adjust toolbars that need adjusting too
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    EPSLog(@"traitCollectionDidChange");
    if ((self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass)
        || (self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass)) {
        // note that this fixes menus for future use after rotation, but it doesn't immediately change font
        // size on involved menus (until menu is changed).
        [self fixupMenus:[self isCompactSizeClass]];
        
        [self.toggleIntervalRateButton setTitle:[self selectSize:TOGGLE_INT_RATE_IPAD compactSize:TOGGLE_INT_RATE_IPHONE]];
        [self.mRRButton setTitle:[self selectSize:MEAN_RATE_IPAD compactSize:MEAN_RATE_IPHONE]];
        [self.calibrateCalipersButton setTitle:[self selectSize:CALIBRATE_IPAD compactSize:CALIBRATE_IPHONE]];
        if (self.chosenCaliper != nil) {
            [self.componentLabel setText:[self.chosenCaliper getComponentName:self.chosenCaliperComponent smallSize:[self isCompactSizeClass]]];
            [self.componentLabel sizeToFit];
        }
    }
}

- (void)lockImage {
    self.calipersView.lockImageScreen = !self.calipersView.lockImageScreen;
    if (self.calipersView.lockImageScreen) {
        self.lockImageButton.title = [self selectSize:UNLOCK_IPAD compactSize:UNLOCK_IPHONE];
    }
    else {
        self.lockImageButton.title = [self selectSize:LOCK_IPAD compactSize:LOCK_IPHONE];
    }
    [self.scrollView setUserInteractionEnabled:!self.calipersView.lockImageScreen];
    [self.calipersView setNeedsDisplay];
}

#pragma mark - CalipersViewDelegate Methods

// from https://github.com/fcanas/ios-color-picker
- (void)chooseColor:(Caliper *)caliper {
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.backgroundColor = [UIColor whiteColor];
    self.chosenCaliper = caliper;
    colorPicker.color = caliper.unselectedColor;
    colorPicker.delegate = self;
    
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}

- (void)tweakComponent:(CaliperComponent)component forCaliper:(Caliper *)caliper {
    self.chosenCaliper = caliper;
    self.chosenCaliperComponent = component;
    [self.componentLabel setText:[caliper getComponentName:component smallSize:[self isCompactSizeClass]]];
    [self.componentLabel sizeToFit];
    BOOL disableUpDown = caliper.direction == Horizontal && component != Crossbar;
    BOOL disableLeftRight = caliper.direction == Vertical && component != Crossbar;
    self.upButton.enabled = !disableUpDown;
    self.microUpButton.enabled = !disableUpDown;
    self.downButton.enabled = !disableUpDown;
    self.microDownButton.enabled = !disableUpDown;
    self.leftButton.enabled = !disableLeftRight;
    self.microLeftButton.enabled = !disableLeftRight;
    self.rightButton.enabled = !disableLeftRight;
    self.microRightButton.enabled = !disableLeftRight;
    [self selectMovementToolbar];
}

- (void)moveComponent:(Caliper *)caliper component:(CaliperComponent)component distance:(CGFloat)distance direction:(MovementDirection)direction {
    if (caliper == nil || component == None) {
        return;
    }
    [caliper moveBarInDirection:direction distance:distance forComponent:component];
    [self.calipersView setNeedsDisplay];

}

- (void)moveLeft {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MOVEMENT direction:Left];
}

- (void)moveRight {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MOVEMENT direction:Right];
}

- (void)moveUp {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MOVEMENT direction:Up];
}

- (void)moveDown {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MOVEMENT direction:Down];
}

- (void)microMoveLeft {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MICRO_MOVEMENT direction:Left];
}

- (void)microMoveRight {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MICRO_MOVEMENT direction:Right];
}

- (void)microMoveUp {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MICRO_MOVEMENT direction:Up];
}

- (void)microMoveDown {
    [self moveComponent:self.chosenCaliper component:self.chosenCaliperComponent distance:MICRO_MOVEMENT direction:Down];
}



#pragma mark - FCColorPickerViewControllerDelegate Methods

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    if (self.chosenCaliper != nil) {
        self.chosenCaliper.color = color;
        self.chosenCaliper.unselectedColor = color;
        self.chosenCaliper.selected = NO;
        [self.calipersView setNeedsDisplay];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - restore view controller state

// see https://useyourloaf.com/blog/state-preservation-and-restoration/
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    EPSLog(@"encodeRestorableStateWithCoder");
    // possibly enable restart from URL
    [coder encodeObject:self.launchURL forKey:@"LaunchURL"];
    [coder encodeInteger:self.numberOfPages forKey:@"NumberOfPages"];
    [coder encodeObject:UIImagePNGRepresentation(self.imageView.image)
                 forKey:@"SavedImageKey"];
    [coder encodeDouble:(double)self.scrollView.zoomScale forKey:@"ZoomScaleKey"];
    
    // calibration
    [self.horizontalCalibration encodeCalibrationState:coder withPrefix:@"Horizontal"];
    [self.verticalCalibration encodeCalibrationState:coder withPrefix:@"Vertical"];
    
    // calipers
    [coder encodeInteger:[self.calipersView count] forKey:@"CalipersCount"];
    [coder encodeBool:self.calipersView.aCaliperIsMarching forKey:@"ACaliperIsMarching"];
    for (int i = 0; i < [self.calipersView count]; i++) {
        [self.calipersView.calipers[i] encodeCaliperState:coder withPrefix:[NSString stringWithFormat:@"%d", i]];
        EPSLog(@"calipers is Angle %d", [self.calipersView.calipers[i] isAngleCaliper]);
    }
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    EPSLog(@"decodeRestorableStateWithCoder");
    self.launchURL = [coder decodeObjectForKey:@"LaunchURL"];
    self.numberOfPages = (int)[coder decodeIntegerForKey:@"NumberOfPages"];
    if (self.launchURL != nil && self.numberOfPages > 0) {
        EPSLog(@"Multipage PDF");
        self.wasLaunchedFromUrl = YES;
    }
    self.imageView.image = [UIImage imageWithData:[coder decodeObjectForKey:@"SavedImageKey"]];
    self.scrollView.zoomScale = [coder decodeDoubleForKey:@"ZoomScaleKey"];
    
    // calibration
    [self.horizontalCalibration decodeCalibrationState:coder withPrefix:@"Horizontal"];
    [self.verticalCalibration decodeCalibrationState:coder withPrefix:@"Vertical"];
    
    // calipers
    NSInteger calipersCount = [coder decodeIntegerForKey:@"CalipersCount"];
    self.calipersView.aCaliperIsMarching = [coder decodeBoolForKey:@"ACaliperIsMarching"];
    for (int i = 0; i < calipersCount; i++) {
        BOOL isAngleCaliper = [coder decodeBoolForKey:[NSString stringWithFormat:@"%dIsAngleCaliper", i]];
        CaliperType type = isAngleCaliper ? Angle : Interval;
        Caliper *newCaliper = [CaliperFactory createCaliper:type];
        [newCaliper decodeCaliperState:coder withPrefix:[NSString stringWithFormat:@"%d", i]];
        if (newCaliper.direction == Horizontal) {
            newCaliper.calibration = self.horizontalCalibration;
        }
        else {
            newCaliper.calibration = self.verticalCalibration;
        }
        if ([newCaliper isAngleCaliper]) {
            ((AngleCaliper *)newCaliper).verticalCalibration = self.verticalCalibration;
        }
        [self.calipersView.calipers addObject:newCaliper];
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
