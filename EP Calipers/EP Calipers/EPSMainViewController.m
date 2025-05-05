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
#import "Alert.h"
#import "Version.h"
#import "Translation.h"
#import "HelpViewController.h"
#import "EP_Calipers-Swift.h"
#import "Defs.h"
#import <os/log.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PencilKit/PencilKit.h>

// These can't be yes for release version
#ifdef DEBUG
// Set to yes to always show startup screen, for testing
#define TEST_QUICK_START NO
// Set to YES to show PDF menu regardless of their being a PDF
#define SHOW_PDF_MENU NO
#else
// These settings are for the release version.  Don't change them!!
#define TEST_QUICK_START NO
#define SHOW_PDF_MENU NO
#endif

// Minimum press duration for long presses (default = 0.5)
#define MINIMUM_PRESS_DURATION 0.8
#define ANIMATION_DURATION 0.5
#define MIN_ZOOM 0.25
#define MAX_ZOOM 10.0
#define MOVEMENT 1.0f
#define MICRO_MOVEMENT 0.1f
#define MAX_BLACKVIEW_ALPHA 0.4f
#define PDF_UPSCALE_FACTOR 5.0

#define IMAGE_TINT [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]

// Arrows
#define LEFT_ARROW @"⇦"
#define RIGHT_ARROW @"⇨"
#define MICRO_LEFT_ARROW @"←"
#define MICRO_RIGHT_ARROW @"→"
#define UP_ARROW @"⇧"
#define DOWN_ARROW @"⇩"
#define MICRO_UP_ARROW @"↑"
#define MICRO_DOWN_ARROW @"↓"

// Language for localization
#define LANG L(@"lang")

// Translated strings
#define CALIPERS_VIEW_TITLE L(@"EP Calipers")
#define CALIBRATE L(@"Calibrate")
#define CALIBRATE_IPAD L(@"Calibrate")
#define CALIBRATE_IPHONE L(@"Calibrate")
#define TOGGLE_INT_RATE_IPAD L(@"Interval_rate_ipad")
#define TOGGLE_INT_RATE_IPHONE L(@"Interval_rate_iphone")
#define MEAN_RATE_IPAD L(@"Mean_rate_ipad")
#define MEAN_RATE_IPHONE L(@"Mean_rate_iphone")
#define CANCEL L(@"Cancel")
#define SET L(@"Set")
#define CLEAR L(@"Clear")
#define OK L(@"OK")
#define DELETE L(@"Delete")
#define DONE L(@"Done")

#define COLOR L(@"Color")
#define TWEAK L(@"Tweak")
#define MARCH L(@"March")

#define ROTATE L(@"Rotate")
#define FLIP L(@"Flip")
#define RESET L(@"Reset")
#define PDF L(@"PDF")

#define LOCK_IPAD L(@"Lock-iPad")
#define LOCK_IPHONE L(@"Lock-iPhone")
#define UNLOCK_IPAD L(@"Unlock-iPad")
#define UNLOCK_IPHONE L(@"Unlock-iPhone")

// For future use
#define BRUGADA_IPAD L(@"Brugada_ipad")
#define BRUGADA_IPHONE L(@"Brugada_iphone")
#define LOW_BRUGADA_RISK L(@"Low_brugada_risk")
#define BRUGADA_BASE_MEASUREMENT L(@"Brugada_base_measurement")
#define BRUGADA_RISK_STATEMENT L(@"Brugada_risk_statement")
#define BRUGADA_CALIBRATION_STATEMENT L(@"Brugada_calibration_statement")
#define BRUGADA_BETA_ANGLE L(@"Brugada_beta_angle")
#define BRUGADA_RESULTS_TITLE L(@"Brugada_results_title")
#define BRUGADA_INCREASED_RISK L(@"Brugada_increased_risk")

// Tooltips
#define ADD_TOOLTIP L(@"Add_tooltip")
#define SIDE_MENU_TOOLTIP L(@"Side_menu_tooltip")
#define MOVE_CALIPER_TOOLTIP L(@"Move_caliper_tooltip")
#define MEASUREMENT_TOOLTIP L(@"Measurement_tooltip")
#define MOVE_IMAGE_TOOLTIP L(@"Move_image_tooltip")
#define LONGPRESS_TOOLTIP L(@"Longpress_tooltip")
#define SETUP_CALIBRATION_TOOLTIP L(@"Setup_calibration_tooltip")
#define SET_CALIBRATION_TOOLTIP L(@"Set_calibration_tooltip")
#define CLEAR_CALIBRATION_TOOLTIP L(@"Clear_calibration_tooltip")
#define INT_RATE_TOOLTIP L(@"Int_rate_tooltip")
#define MEAN_RATE_TOOLTIP L(@"Mean_rate_tooltip")
#define QTC_TOOLTIP L(@"QTc_tooltip")
#define QTC_STEP_1_TOOLTIP L(@"QTc_step_1_tooltip")
#define QTC_STEP_2_TOOLTIP L(@"QTc_step_2_tooltip")
#define SNAPSHOT_TOOLTIP L(@"Snapshot_screen")
#define SCRIBBLE_TOOLTIP L(@"Scribble_tooltip")

// Dialog titles and messages
#define ADD_CALIPER L(@"Add_caliper")
#define TIME_CALIPER L(@"Time_caliper")
#define AMPLITUDE_CALIPER L(@"Amplitude_caliper")
#define ANGLE_CALIPER L(@"Angle_caliper")
#define NUMBER_OF_INTERVALS L(@"Number_of_intervals")
#define HOW_MANY_INTERVALS L(@"How_many_intervals")
#define NEGATIVE_CALIPER L(@"Negative_caliper")
#define NEGATIVE_CALIPER_MESSAGE L(@"Negative_caliper_message")
#define NO_CALIPERS_TO_USE L(@"No_calipers_to_use")
#define ADD_SOME_CALIPERS L(@"Add_some_calipers")
#define BAD_INPUT L(@"Bad_input")
#define EMPTY_BAD_INPUT L(@"Empty_bad_input")
#define BAD_UNITS L(@"Bad_units")
#define BAD_UNITS_WARNING L(@"Bad_units_warning")
#define NO_UNITS_WARNING L(@"No_units_warning")
#define CALIBRATE_ANYWAY L(@"Calibrate_anyway")
#define SELECT_ANGLE_CALIPER L(@"Select_angle_caliper")
#define NO_ANGLE_CALIPER_SELECTED L(@"No_angle_caliper_selected")
#define MULTIPAGE_PDF L(@"Multipage_pdf")
#define MULTIPAGE_PDF_WARNING L(@"Multipage_pdf_warning")
#define NO_TIME_CALIPER_SELECTED_MESSAGE L(@"No_time_caliper_selected_message")
#define SELECT_TIME_CALIPER_MESSAGE L(@"Select_time_caliper_message")
#define MEAN_INTERVAL_RATE_LABEL L(@"Mean_interval_rate_label")
#define MEAN_INTERVAL_RATE_RESULT L(@"Mean_interval_rate_result")
#define NO_CALIPER_SELECTED_MESSAGE L(@"No_caliper_selected_message")
#define CALIBRATION_INSTRUCTIONS L(@"Calibration_instructions")
#define DO_NOT_CALIBRATE_ANGLE_CALIPERS L(@"Do_not_calibrate_angle_calipers")
#define ENTER_MEASUREMENT L(@"Enter_measurement")
#define QTC L(@"QTc")
#define CALCULATED_QTC L(@"Calculated_qtc")
#define REPEAT_QT L(@"Repeat_qt")
#define GO_TO L(@"Go_to")
#define GO_TO_PAGE L(@"Go_to_page")
#define ROTATE_90_R L(@"Rotate_90_R")
#define ROTATE_90_L L(@"Rotate_90_L")
#define ROTATE_1_R L(@"Rotate_1_R")
#define ROTATE_1_L L(@"Rotate_1_L")
#define ROTATE_01_R L(@"Rotate_01_R")
#define ROTATE_01_L L(@"Rotate_01_L")
#define NUM_RRS L(@"Num_RRs")
#define QT L(@"QT")
#define MEASURE L(@"Measure")
#define CALCULATE L(@"Calculate")
#define THREE L(@"Three")
#define ONE L(@"One")
#define AMPLITUDE_CAL_EXAMPLE L(@"Amplitude_cal_example")
#define TIME_CAL_EXAMPLE L(@"Time_cal_example")
#define CAMERA_NOT_AVAILABLE_TITLE L(@"Camera_not_available_title")
#define CAMERA_NOT_AVAILABLE_MESSAGE L(@"Camera_not_available_message")
#define PHOTO_LIBRARY_NOT_AVAILABLE_TITLE L(@"Photo_library_not_available_title")
#define PHOTO_LIBRARY_NOT_AVAILABLE_MESSAGE L(@"Photo_library_not_available_message")
#define IMAGE_SOURCE L(@"Image_source")
#define PHOTOS_SOURCE L(@"Photos_source")
#define FILES_SOURCE L(@"Files_source")
#define CAMERA_PERMISSION_DENIED_TITLE L(@"Camera_permission_denied_title")
#define CAMERA_PERMISSION_DENIED_MESSAGE L(@"Camera_permission_denied_message")

// Font sizes
#define VERY_SMALL_FONT 10
#define SMALL_FONT 12
#define INTERMEDIATE_FONT 14

// State restoration keys
#define LAUNCH_URL_KEY @"LaunchURL"
#define NUMBER_OF_PAGES_KEY @"NumberOfPages"
#define SAVED_IMAGE_STRING_KEY @"SavedImageStringKey"
#define ZOOM_SCALE_KEY @"ZoomScaleKey"
#define IMAGE_IS_UPSCALED_KEY @"ImageIsUpscaledKey"
#define HORIZONATAL_PREFIX_KEY @"Horizontal"
#define VERTICAL_PREFIX_KEY @"Vertical"
#define CALIPERS_COUNT_KEY @"CalipersCount"
#define A_CALIPER_IS_MARCHING_KEY @"ACaliperIsMarching"
#define IS_ANGLE_CALIPER_FORMAT_KEY @"%dIsAngleCaliper"
#define CANVAS_VIEW_DRAWING_STRING_KEY @"CanvasViewDrawingString"


#define FLEX_SPACE [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]

@interface EPSMainViewController ()

@property (strong, nonatomic) UIFont *verySmallFont;
@property (strong, nonatomic) NSDictionary *verySmallFontAttributes;
@property (strong, nonatomic) UIFont *smallFont;
@property (strong, nonatomic) NSDictionary *smallFontAttributes;
@property (strong, nonatomic) UIFont *intermediateFont;
@property (strong, nonatomic) NSDictionary *intermediateFontAttributes;
@property (strong, nonatomic) UIFont *regularFont;
@property (strong, nonatomic) NSDictionary *regularFontAttributes;
@property (nonatomic) CGPoint pressLocation;

// Tooltips
@property (strong, nonatomic) CMPopTipView *addCaliperButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *snapshotButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *scribbleButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *sideMenuButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *setupCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *setCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *clearCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *intRateButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *meanRateButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *calculateQTcPopTipView;
@property (strong, nonatomic) CMPopTipView *qtcStep1ButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *qtcStep2ButtonPopTipView;

// Toggles for individual tooltips
@property (nonatomic) BOOL showAddCaliperButtonToolTip;
@property (nonatomic) BOOL showSnapshotButtonToolTip;
@property (nonatomic) BOOL showScribbleButtonToolTip;
@property (nonatomic) BOOL showSideMenuButtonToolTip;
@property (nonatomic) BOOL showSetupCalibrationToolTip;
@property (nonatomic) BOOL showSetCalibrationToolTip;
@property (nonatomic) BOOL showClearCalibrationToolTip;
@property (nonatomic) BOOL showIntRateToolTip;
@property (nonatomic) BOOL showMeanRateToolTip;
@property (nonatomic) BOOL showCalculateQTcToolTip;
@property (nonatomic) BOOL showQtcStep1ToolTip;
@property (nonatomic) BOOL showQtcStep2ToolTip;

@property (nonatomic) CGAffineTransform imageTransform;
@property (nonatomic) BOOL imageIsUpscaled;

@end

@implementation EPSMainViewController 
{
    CGPDFDocumentRef pdfRef;
    // Direction of writing in primary language.
    BOOL isLeftToRight;
}

- (void)loadFonts {
    NSUInteger verySmallFontSize = VERY_SMALL_FONT;
    self.verySmallFont = [UIFont boldSystemFontOfSize:verySmallFontSize];
    self.verySmallFontAttributes = @{NSFontAttributeName: self.verySmallFont};
    NSUInteger smallFontSize = SMALL_FONT;
    self.smallFont = [UIFont boldSystemFontOfSize:smallFontSize];
    self.smallFontAttributes = @{NSFontAttributeName: self.smallFont};
    NSUInteger intermediateFontSize = INTERMEDIATE_FONT;
    self.intermediateFont = [UIFont boldSystemFontOfSize:intermediateFontSize];
    self.intermediateFontAttributes = @{NSFontAttributeName: self.intermediateFont};
    self.regularFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    self.regularFontAttributes = @{NSFontAttributeName: self.regularFont};
    EPSLog(@"Regular font = %f", self.regularFont.pointSize);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"viewDidLoad");

    pdfRef = NULL;
    self.imageIsUpscaled = NO;
    self.maxBlackAlpha = MAX_BLACKVIEW_ALPHA;

    self.pressLocation = CGPointMake(0, 0);

    self.settings = [[Settings alloc] init];
    [self.settings loadPreferences];

    [self loadFonts];

    [self createToolbars];

    self.blackView.delegate = self;

    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];

    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = MIN_ZOOM;
    self.scrollView.maximumZoomScale = MAX_ZOOM;

    // init calibration
    self.horizontalCalibration = [[Calibration alloc] init];
    self.horizontalCalibration.direction = Horizontal;
    self.verticalCalibration = [[Calibration alloc] init];
    self.verticalCalibration.direction = Vertical;
    self.defaultHorizontalCalChanged = NO;
    self.defaultVerticalCalChanged = NO;
    
    [self.calipersView setUserInteractionEnabled:YES];
    self.calipersView.delegate = self;
    // for debugging
    //self.calipersView.alpha = 0.5;
    //self.calipersView.backgroundColor = [UIColor redColor];

    // init QTc variables
    self.rrIntervalForQTc = 0.0;
    self.inQtc = NO;
    self.inRRForQTc = NO;

    // ImageView must have a non-clear background color, or PDFs don't work.
    self.imageView.backgroundColor = [self getImageViewBackgroundColor];

    // hide hamburger menu
    self.constraintHamburgerLeft.constant = -self.constraintHamburgerWidth.constant;
    self.hamburgerMenuIsOpen = NO;
    self.hamburgerViewController.imageIsLocked = self.imageIsLocked;
    self.blackView.alpha = 0;

    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddCaliperMenu)];
    UIBarButtonItem *screenshotItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"snapshot"] style:UIBarButtonItemStylePlain target:self action:@selector(snapshotScreen)];
    UIBarButtonItem *scribbleItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"scribble"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleCanvasView)];
    // Buttons are added from right to left
    if ([self canHaveCanvasView]) {
        self.navigationItem.rightBarButtonItems = @[addCaliperButton, screenshotItem, scribbleItem];
    }
    else {
        self.navigationItem.rightBarButtonItems = @[addCaliperButton, screenshotItem];
    }
    // icon from https://icons8.com/icon/set/hamburger/ios
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleHamburgerMenu)];
    [self.navigationItem setTitle:CALIPERS_VIEW_TITLE];

    [self setupTheme];

    self.isCalipersView = YES;

    // Not sure this makes a difference anymore.
    self.edgesForExtendedLayout = UIRectEdgeNone;   // nav & toolbar don't overlap view

    self.firstRun = YES;
    self.wasLaunchedFromUrl = NO;

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBackToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

    // Touches
    UILongPressGestureRecognizer *longPressScrollView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doScrollViewLongPress:)];
    [longPressScrollView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
    [self.scrollView addGestureRecognizer:longPressScrollView];

    UILongPressGestureRecognizer *longPressCalipersView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doCalipersViewLongPress:)];
    [longPressCalipersView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
    [self.calipersView addGestureRecognizer:longPressCalipersView];

    [self createCanvasView];
}

- (BOOL)isIpad {
    UIDevice *device = [UIDevice currentDevice];
    return [device userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (void) orientationChanged:(NSNotification *)notification {
    // To avoid zoomed images from getting off-center, we recenter with rotation.
    [self recenterImage];
}

- (UIColor *)getImageViewBackgroundColor {
    // After experimentation, white background color seems best.
    // BUT, maybe not so much for dark mode...
    // However, can't use this for PDFs!
    return [UIColor tertiarySystemBackgroundColor];
}

- (void)setupTheme {
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;

    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];

    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    UIToolbarAppearance *toolbarAppearance = [[UIToolbarAppearance alloc] init];
    [navigationBarAppearance configureWithOpaqueBackground];
    [toolbarAppearance configureWithOpaqueBackground];
    navigationBarAppearance.backgroundColor = [UIColor systemBackgroundColor];
    toolbarAppearance.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationController.navigationBar.standardAppearance = navigationBarAppearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
    self.navigationController.toolbar.standardAppearance = toolbarAppearance;
    if (@available(iOS 15.0, *)) {
        self.navigationController.toolbar.scrollEdgeAppearance = toolbarAppearance;
    } else {
        // Fallback on earlier versions
    }
    self.navigationController.navigationBar.barTintColor = [UIColor systemBackgroundColor];
    self.navigationController.toolbar.barTintColor = [UIColor systemBackgroundColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewBackToForeground {
    EPSLog(@"ViewBackToForeground");
    NSString *priorHorizontalDefaultCal = [NSString stringWithString:self.settings.defaultCalibration];
    NSString *priorVerticalDefaultCal = [NSString stringWithString:self.settings.defaultVerticalCalibration];
    [self.settings loadPreferences];
    [self setupTheme];
    self.defaultHorizontalCalChanged = ![priorHorizontalDefaultCal isEqualToString:self.settings.defaultCalibration];
    self.defaultVerticalCalChanged = ![priorVerticalDefaultCal isEqualToString:self.settings.defaultVerticalCalibration];
    [self.calipersView updateCaliperPreferences:self.settings.caliperColor selectedColor:self.settings.highlightColor lineWidth:self.settings.lineWidth roundMsec:self.settings.roundMsecRate autoPositionText:self.settings.autoPositionText timeTextPosition:self.settings.timeTextPosition amplitudeTextPosition:self.settings.amplitudeTextPosition];
    [self.calipersView setNeedsDisplay];

}

- (void)recenterImage {
    EPSLog(@"Recenter image");
    [self centerContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    EPSLog(@"ViewDidAppear");

    // Sometimes calipers are malpositioned when view restored.
    [self.calipersView setNeedsDisplay];

    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];

    if (self.firstRun) {
        // scale image for imageView;
        // autolayout not done in viewDidLoad
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
//
//        UIStatusBarManager *statusBarManager = [self.view.window windowScene].statusBarManager;
//        CGFloat statusBarHeight = 0;
//        if (statusBarManager != nil) {
//            statusBarHeight = statusBarManager.statusBarFrame.size.height;
//        }
//        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
//        CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
//        CGFloat verticalSpace = statusBarHeight + navigationBarHeight + toolbarHeight;
//
//        self.portraitWidth = fminf(screenHeight, screenWidth);
//        self.landscapeWidth = fmaxf(screenHeight, screenWidth);
//        self.portraitHeight = fmaxf(screenHeight, screenWidth) - verticalSpace;
//        self.landscapeHeight = fminf(screenHeight, screenWidth) - verticalSpace;

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
            if (self.numberOfPages > 1) {
                [Alert showSimpleAlertWithTitle:MULTIPAGE_PDF message:MULTIPAGE_PDF_WARNING viewController:self];
            }
            self.launchURL = nil;
            self.numberOfPages = 0;
            self.wasLaunchedFromUrl = NO;
        }

        // Recenter image after app restored.
        //[self recenterImage];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self recenterImage];
        });

        self.firstRun = NO;
        self.firstStart = NO;

        if (TEST_QUICK_START || [self shouldShowTooltipsAtStart]) {
            self.firstStart = YES;
            [self showHelp];
            self.firstStart = NO;
            [self showToolTips];
        }

        if (self.isNewInstallation || self.isUpgrade) {
            [[NSUserDefaults standardUserDefaults] setObject:[Version getAppVersion] forKey:@"AppVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        // When starting add a caliper if one isn't there already
        if ([self.calipersView count] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self addHorizontalCaliper];
            });
        }
        [self selectMainToolbar];

        EPSLog(@"scrollView = %f, calipersView height = %f", self.scrollView.frame.size.height, self.calipersView.frame.size.height);
//        assert(self.scrollView.contentSize.height == self.calipersView.frame.size.height);
    }

}

- (BOOL)canHaveCanvasView {
    // Maybe we will allow something else besides iPad to have a canvas
    // view in the future, but for now, it's just on iPads.
    return [self isIpad];
}

- (void)clearCanvasView {
    EPSLog(@"Clear CanvasView");
    [self createCanvasView];
}

// Sync two scrollviews together during scrolling, zoom
// See https://stackoverflow.com/questions/9418311/setting-contentoffset-programmatically-triggers-scrollviewdidscroll
// Sets canvasView to nil if canvasView not supported.
- (void)createCanvasView {
    if (![self canHaveCanvasView]) {
        self.canvasView = nil;
        return;
    }

    self.canvasView = [[PKCanvasView alloc] initWithFrame:CGRectZero];
    self.canvasView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.canvasView setOpaque:NO];
    self.canvasView.backgroundColor = [UIColor clearColor];
    self.canvasView.maximumZoomScale = self.scrollView.maximumZoomScale;
    self.canvasView.minimumZoomScale = self.scrollView.minimumZoomScale;
    self.canvasView.delegate = self;
    [self.view addSubview:self.canvasView];
    [self.view bringSubviewToFront:self.canvasView];
    self.canvasView.hidden = YES;
    [NSLayoutConstraint activateConstraints:@[
        [self.canvasView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.canvasView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.canvasView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.canvasView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor]]];
    self.toolPicker = [[PKToolPicker alloc] init];
    [self.toolPicker setVisible:YES forFirstResponder:self.canvasView];
    [self.toolPicker addObserver:self.canvasView];
    [self.canvasView resignFirstResponder];
    [self.canvasView setUserInteractionEnabled:NO];
}

- (void)doCanvasViewLongPress:(UILongPressGestureRecognizer *) sender {
    EPSLog(@"Canvas View Long Press");
}

- (void)toggleCanvasView {
    if (![self canHaveCanvasView]) {
        return;
    }
    if (nil == self.scribbleButtonPopTipView && self.showScribbleButtonToolTip) {
        self.scribbleButtonPopTipView = [[CMPopTipView alloc] initWithMessage:SCRIBBLE_TOOLTIP];
        [self setupToolTip:self.scribbleButtonPopTipView];
        [self.scribbleButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItems[2]  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.scribbleButtonPopTipView dismissAnimated:YES];
        self.scribbleButtonPopTipView = nil;
        self.showScribbleButtonToolTip = NO;
    }

    [self performToggleCanvasView];
}

- (void)performToggleCanvasView {
    self.canvasView.hidden = !self.canvasView.hidden;
    [self hideCanvasView:self.canvasView.hidden];
}

- (void)hideCanvasView:(BOOL)hide {
    if (hide) {
        // setting hidden here again may seem redundant, as it is already
        // set in performToggleCanvasView; however, hideCanvasView is also
        // called during state restoration, which does not set canvasView.hidden
        // directly.
        EPSLog(@"Hiding canvas view");
        self.canvasView.hidden = YES;
        [self.toolPicker setVisible:YES forFirstResponder:self.canvasView];
        [self.toolPicker addObserver:self.canvasView];
        [self.canvasView resignFirstResponder];
        [self.canvasView setUserInteractionEnabled:NO];
        [self scaleCanvasView];
        // Do not animate hiding toolbar, as it will cause an animation to
        // appear in the calipers.
        [self.navigationController setToolbarHidden:NO animated:NO];
        [self.calipersView setNeedsDisplay];
        self.navigationItem.leftBarButtonItems[0].enabled = YES;
        self.navigationItem.rightBarButtonItems[0].enabled = YES;
        // Can't just have canvas view resign first responder, because if
        // there has been a long press on the canvas view, the canvas view
        // does not resign first responder properly and the pencil tools
        // don't go away.  Must explicity make the scrollView first responder again.
        [self.scrollView becomeFirstResponder];
    } else {
        EPSLog(@"Showing canvas view");
        self.navigationItem.rightBarButtonItems[0].enabled = NO;
        self.navigationItem.leftBarButtonItems[0].enabled = NO;
        [self scaleCanvasView];
        [self.toolPicker setVisible:YES forFirstResponder:self.canvasView];
        [self.toolPicker addObserver:self.canvasView];
        [self.canvasView becomeFirstResponder];
        [self.canvasView setUserInteractionEnabled:YES];
        [self.navigationController setToolbarHidden:YES animated:NO];
        [self.calipersView setNeedsDisplay];
        self.canvasView.hidden = NO;
        [self recenterImage];
    }
    EPSLog(@"Canvas view is first responder = %d", [self.canvasView isFirstResponder]);
}

- (void)scaleCanvasView {
    if (![self canHaveCanvasView]) {
        return;
    }
    self.canvasView.contentSize = self.scrollView.contentSize;
    self.canvasView.contentInset = self.scrollView.contentInset;
    self.canvasView.contentOffset = self.scrollView.contentOffset;
    self.canvasView.zoomScale = self.scrollView.zoomScale;
}

- (void)showToolTips {
    // This method is a toggle.  Turn off tool tips if showing them.
    if (self.showingToolTips) {
        [self disableToolTips];
        return;
    }
    [self initToolTips];
}

- (BOOL)shouldShowTooltipsAtStart {
    EPSLog(@"Previous app version = %@", self.priorVersion);
    EPSLog(@"Current app version = %@", self.currentVersion);
    EPSLog(@"Previous app major version = %@", self.priorMajorVersion);
    if (self.isNewInstallation) {
        return YES;
    }
    // Only show tooltips at startup if upgrade is from version 1 or 2
    if (self.isUpgrade && (self.priorMajorVersion == nil || [self.priorMajorVersion  isEqual: @"1"] || [self.priorMajorVersion  isEqual: @"2"])) {
        return YES;
    }
    return NO;
}

- (void)setToolTipState:(BOOL)value {
    self.showAddCaliperButtonToolTip = value;
    self.showSnapshotButtonToolTip = value;
    self.showScribbleButtonToolTip = value;
    self.showSideMenuButtonToolTip = value;
    self.showSetupCalibrationToolTip = value;
    self.showSetCalibrationToolTip = value;
    self.showClearCalibrationToolTip = value;
    self.showIntRateToolTip = value;
    self.showMeanRateToolTip = value;
    self.showCalculateQTcToolTip = value;
    self.showQtcStep1ToolTip = value;
    self.showQtcStep2ToolTip = value;
}

- (void)initToolTips {
    [self setToolTipState:YES];
    [self stillShowingToolTips];
}

- (void)disableToolTips {
    [self setToolTipState:NO];
    [self stillShowingToolTips];
}

- (void)stillShowingToolTips {
    BOOL toolTipsRemain = self.showSetupCalibrationToolTip || self.showSetCalibrationToolTip || self.showIntRateToolTip || self.showMeanRateToolTip || self.showClearCalibrationToolTip || self.showQtcStep1ToolTip || self.showQtcStep2ToolTip ||
    self.showAddCaliperButtonToolTip || self.showSnapshotButtonToolTip ||
    (self.showScribbleButtonToolTip && [self canHaveCanvasView]);
    self.showingToolTips = toolTipsRemain;
    self.hamburgerViewController.showingToolTips = self.showingToolTips;
}

- (void)setupToolTip:(CMPopTipView *)toolTip {
    toolTip.delegate = self;
    toolTip.dismissTapAnywhere = YES;
    toolTip.has3DStyle = NO;
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    if ([popTipView isEqual:self.addCaliperButtonPopTipView]) {
        self.showAddCaliperButtonToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.snapshotButtonPopTipView]) {
        self.showSnapshotButtonToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.scribbleButtonPopTipView]) {
        self.showScribbleButtonToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.sideMenuButtonPopTipView]) {
        self.showSideMenuButtonToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.setupCalibrationButtonPopTipView]) {
        self.showSetupCalibrationToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.setCalibrationButtonPopTipView]) {
        self.showSetCalibrationToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.clearCalibrationButtonPopTipView]) {
        self.showClearCalibrationToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.intRateButtonPopTipView]) {
        self.showIntRateToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.meanRateButtonPopTipView]) {
        self.showMeanRateToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.calculateQTcPopTipView]) {
        self.showCalculateQTcToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.qtcStep1ButtonPopTipView]) {
        self.showQtcStep1ToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([popTipView isEqual:self.qtcStep2ButtonPopTipView]) {
        self.showQtcStep2ToolTip = NO;
        [self stillShowingToolTips];
    }
}

- (NSString *)applicationLanguage {
    return LANG;
}

// Have to adjust font sizes for Russian, so need to know what language we are using.
- (BOOL)usingRussian {
    return [[self applicationLanguage] isEqualToString:@"ru"];
}

- (void)doCalipersViewLongPress:(UILongPressGestureRecognizer *)sender {
    EPSLog(@"long press calipers view from main");
    if (sender.state != UIGestureRecognizerStateBegan || self.hamburgerMenuIsOpen) {
        return;
    }
    [sender.view becomeFirstResponder];
    CGPoint location = [sender locationInView:sender.view];
    self.pressLocation = location;
    if (self.tweakingInProgress) {
        [self tweakAction];
        return;
    }
    UIMenuController *menu = UIMenuController.sharedMenuController;
    menu.arrowDirection = UIMenuControllerArrowDefault;
    UIMenuItem *colorMenuItem = [[UIMenuItem alloc] initWithTitle:COLOR action:@selector(colorAction)];
    UIMenuItem *tweakMenuItem = [[UIMenuItem alloc] initWithTitle:TWEAK action:@selector(tweakAction)];
    UIMenuItem *marchMenuItem = [[UIMenuItem alloc] initWithTitle:MARCH action:@selector(marchAction)];
    UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:DELETE action:@selector((deleteAction))];
    UIMenuItem *doneMenuItem = [[UIMenuItem alloc] initWithTitle:DONE action:@selector(doneMenuAction)];
    // Only include march menu if we are on a time caliper.
    if ([self.calipersView caliperNearLocationIsTimeCaliper:location]) {
        menu.menuItems = @[colorMenuItem, tweakMenuItem, marchMenuItem, deleteMenuItem, doneMenuItem];
    }
    else {
        menu.menuItems = @[colorMenuItem, tweakMenuItem, deleteMenuItem, doneMenuItem];
    }
    CGRect rect = CGRectMake(location.x, location.y, 0, 0);
    UIView *superView = sender.view.superview;
    //        [menu setTargetRect:rect inView:superView];
    [menu showMenuFromView:superView rect:rect];
    //        [menu setMenuVisible:YES animated:YES];
}

- (void)doScrollViewLongPress:(UILongPressGestureRecognizer *) sender {
    EPSLog(@"Long press from main");
    if (sender.state != UIGestureRecognizerStateBegan || self.hamburgerMenuIsOpen) {
        return;
    }
    [sender.view becomeFirstResponder];
    EPSLog(@"Sender = %@", sender);
    UIMenuController *menu = UIMenuController.sharedMenuController;
    menu.arrowDirection = UIMenuControllerArrowDefault;
    UIMenuItem *rotateMenuItem = [[UIMenuItem alloc] initWithTitle:ROTATE action:@selector(rotateAction)];
    UIMenuItem *flipMenuItem = [[UIMenuItem alloc] initWithTitle:FLIP action:@selector(flipAction)];
    UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:RESET action:@selector(resetAction)];
    UIMenuItem *doneMenuItem = [[UIMenuItem alloc] initWithTitle:DONE action:@selector(doneMenuAction)];
    // Determine if we add PDF menu item.
    BOOL isMultipagePDF = self.numberOfPages > 1 && pdfRef != NULL;
    if (isMultipagePDF || SHOW_PDF_MENU) {
        UIMenuItem *pdfMenuItem = [[UIMenuItem alloc] initWithTitle:PDF action:@selector(pdfAction)];
        menu.menuItems = @[rotateMenuItem, flipMenuItem, resetMenuItem, pdfMenuItem, doneMenuItem];
    }
    else {
        menu.menuItems = @[rotateMenuItem, flipMenuItem, resetMenuItem, doneMenuItem];
    }
    CGPoint location = [sender locationInView:sender.view];
    CGPoint offset = self.scrollView.contentOffset;
    CGRect rect = CGRectMake(location.x - offset.x, location.y - offset.y, 0, 0);
    UIView *superView = sender.view.superview;
    //        [menu setTargetRect:rect inView:superView];
    [menu showMenuFromView:superView rect:rect];
    //        [menu setMenuVisible:YES animated:YES];
}

- (void)rotateAction {
    [self selectRotateImageToolbar];
    [self.scrollView resignFirstResponder];
}

- (void)flipAction {
    [self flipImage:self];
    [self.scrollView resignFirstResponder];
}

- (void)resetAction {
    [self resetImage:self];
    [self.scrollView resignFirstResponder];
}

- (void)pdfAction {
    [self selectPDFToolbar];
    [self.scrollView resignFirstResponder];
}

- (void)doneMenuAction {
    [self.scrollView resignFirstResponder];
}

- (void)colorAction {
    [self.calipersView changeColor:self.pressLocation];
    [self.calipersView resignFirstResponder];
}

- (void)tweakAction {
    [self.calipersView tweakPosition:self.pressLocation];
    [self.calipersView resignFirstResponder];
}

- (void)marchAction {
    [self.calipersView toggleShowMarchingCaliper:self.pressLocation];
    [self.calipersView setNeedsDisplay];
    [self.calipersView resignFirstResponder];
}

- (void)deleteAction {
    [self.calipersView deleteCaliper:self.pressLocation];
    //[self.calipersView setNeedsDisplay];
    [self.calipersView resignFirstResponder];

}

- (UIImage *)scaleImageForImageView:(UIImage *)image {
    EPSLog(@"scaleImageForImageView");
    // Downscale upscaled images.
    if (self.imageIsUpscaled) {
        EPSLog(@">>>>>>Downscaling image");
        CGImageRef imageRef = image.CGImage;
        return [UIImage imageWithCGImage:(CGImageRef)imageRef scale:PDF_UPSCALE_FACTOR orientation:UIImageOrientationUp];
    }
    return image;
}

- (UIImage *)resizerImage:(CGSize)size image:(UIImage *)image {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *scaledImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
    return scaledImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAddCaliperMenu {
    if (nil == self.addCaliperButtonPopTipView && self.showAddCaliperButtonToolTip) {
        self.addCaliperButtonPopTipView = [[CMPopTipView alloc] initWithMessage:ADD_TOOLTIP];
        [self setupToolTip:self.addCaliperButtonPopTipView];
        [self.addCaliperButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItems[0]  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.addCaliperButtonPopTipView dismissAnimated:YES];
        self.addCaliperButtonPopTipView = nil;
        self.showAddCaliperButtonToolTip = NO;
    }
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* timeCaliperAction = [UIAlertAction actionWithTitle:TIME_CALIPER style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {[self addHorizontalCaliper];}];

    // Note: This can be done to add images to the actions, but it is not supported
    // by Apple, and doesn't look that great anyway, so no go.
    //[timeCaliperAction setValue:[[UIImage imageNamed:@"time-caliper"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]   forKey:@"image"];

    [actionSheet addAction:timeCaliperAction];
    UIAlertAction* amplitudeCaliperAction = [UIAlertAction actionWithTitle:AMPLITUDE_CALIPER style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {[self addVerticalCaliper];}];
    [actionSheet addAction:amplitudeCaliperAction];
    UIAlertAction* angleCaliperAction = [UIAlertAction actionWithTitle:ANGLE_CALIPER style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {[self addAngleCaliper];}];
    [actionSheet addAction:angleCaliperAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancelAction];
    actionSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)toggleHamburgerMenu {
    if (nil == self.sideMenuButtonPopTipView && self.showSideMenuButtonToolTip) {
        self.sideMenuButtonPopTipView = [[CMPopTipView alloc] initWithMessage:SIDE_MENU_TOOLTIP];
        [self setupToolTip:self.sideMenuButtonPopTipView];
        [self.sideMenuButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.leftBarButtonItem  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.sideMenuButtonPopTipView dismissAnimated:YES];
        self.sideMenuButtonPopTipView = nil;
        self.showSideMenuButtonToolTip = NO;
    }
    if (self.hamburgerMenuIsOpen) {
        [self hideHamburgerMenu];
    }
    else {
        [self showHamburgerMenu];
    }
    [self.calipersView setNeedsDisplay];
}

- (void)showHamburgerMenu {
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.hamburgerViewController reloadData];
    self.constraintHamburgerLeft.constant = 0;
    self.hamburgerMenuIsOpen = YES;
    [self.calipersView setUserInteractionEnabled:NO];
    [self enableRightBarButtonItems:NO];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        [self.view layoutIfNeeded];
        self.blackView.alpha = self.maxBlackAlpha;
    }];
}

- (void)hideHamburgerMenu {
    [self.navigationController setToolbarHidden:NO animated:NO];
    self.constraintHamburgerLeft.constant = -self.constraintHamburgerWidth.constant;
    self.hamburgerMenuIsOpen = NO;
    [self.calipersView setUserInteractionEnabled:YES];
    [self enableRightBarButtonItems:YES];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        [self.view layoutIfNeeded];
        self.blackView.alpha = 0;
    }];
}

- (void)enableRightBarButtonItems:(BOOL)enable {
    self.navigationItem.rightBarButtonItems[0].enabled = enable;
    self.navigationItem.rightBarButtonItems[1].enabled = enable;
    if (self.navigationItem.rightBarButtonItems.count > 2) {
        self.navigationItem.rightBarButtonItems[2].enabled = enable;
    }
}

- (void)showHelp {
    [self performSegueWithIdentifier:@"showHelpSegue" sender:self];
}

- (void)showManual {
    [self performSegueWithIdentifier:@"manualSegue" sender:self];
}

- (void)showAbout {
    [About show];
}

// Create toolbars
- (void)createToolbars {
    [self createMainToolbar];
    [self createPDFToolbar];
    [self rotateImageToolbar];
    [self createSetupCalibrationToolbar];
    [self createQTcStep1Toolbar];
    [self createQTcStep2Toolbar];
    [self createMovementToolbar];
    [self fixupMenus:[self isCompactSizeClass]];
}

- (NSString *)selectSize:(NSString *)regularSize compactSize:(NSString *)compactSize {
    return [self isRegularSizeClass] ? regularSize : compactSize;
}

- (NSArray *)spaceoutToolbar:(NSArray *)items {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < items.count; i++) {
        if (i == 0) {
            array[0] = items[0];
        }
        else {
            [array addObject:FLEX_SPACE];
            [array addObject:items[i]];
        }
    }
    return array;
}

- (void)createMainToolbar {
    self.calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:CALIBRATE_IPAD compactSize:CALIBRATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(setupCalibration)];
    self.toggleIntervalRateButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:TOGGLE_INT_RATE_IPAD compactSize:TOGGLE_INT_RATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(toggleIntervalRate)];
    self.mRRButton = [[UIBarButtonItem alloc] initWithTitle:[self selectSize:MEAN_RATE_IPAD compactSize:MEAN_RATE_IPHONE] style:UIBarButtonItemStylePlain target:self action:@selector(meanRR)];
    self.qtcButton = [[UIBarButtonItem alloc] initWithTitle:QTC style:UIBarButtonItemStylePlain target:self action:@selector(calculateQTc)];
    NSArray *array = [NSArray arrayWithObjects: self.calibrateCalipersButton, self.toggleIntervalRateButton, self.mRRButton, self.qtcButton, /* self.brugadaButton ? */ nil];
    self.mainMenuItems = [self spaceoutToolbar:array];
}

- (void)createPDFToolbar {
    // these 2 buttons only enable for multipage PDFs
    self.nextPageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"whitenextpage"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
    self.previousPageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"whitepreviouspage"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
    UIBarButtonItem *gotoPageButton = [[UIBarButtonItem alloc] initWithTitle:GO_TO style:UIBarButtonItemStylePlain target:self action:@selector(gotoPage)];
    [self enablePageButtons:NO];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(adjustImageDone)];
    NSArray *array = [NSArray arrayWithObjects: self.previousPageButton, self.nextPageButton, gotoPageButton, backToMainMenuButton, nil];
    self.pdfMenuItems = [self spaceoutToolbar:array];
}

- (void)rotateImageToolbar {
    UIBarButtonItem *rotateImageRightButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_90_R style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageRight:)];
    UIBarButtonItem *rotateImageLeftButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_90_L style:UIBarButtonItemStylePlain target:self action:@selector(rotateImageLeft:)];
    UIBarButtonItem *tweakRightButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_1_R style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageRight:)];
    UIBarButtonItem *tweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_1_L style:UIBarButtonItemStylePlain target:self action:@selector(tweakImageLeft:)];
    UIBarButtonItem *microTweakRightButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_01_R style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageRight:)];
    UIBarButtonItem *microTweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:ROTATE_01_L style:UIBarButtonItemStylePlain target:self action:@selector(microTweakImageLeft:)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(adjustImageDone)];

    NSArray *array = [NSArray arrayWithObjects:rotateImageRightButton,
                      rotateImageLeftButton,
                      tweakRightButton,
                      tweakLeftButton,
                      microTweakRightButton,
                      microTweakLeftButton,
                      backToMainMenuButton, nil];
    self.rotateImageMenuItems = [self spaceoutToolbar:array];
}


- (void)createSetupCalibrationToolbar {
    self.setButton = [[UIBarButtonItem alloc] initWithTitle:SET style:UIBarButtonItemStylePlain target:self action:@selector(setCalibration)];
    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:CLEAR style:UIBarButtonItemStylePlain target:self action:@selector(clearCalibration)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectMainToolbar)];

    NSArray * array = [NSArray arrayWithObjects:self.setButton,
                       self.clearButton,
                       cancelButton, nil];
    self.calibrateMenuItems = [self spaceoutToolbar:array];
}

- (void)createQTcStep1Toolbar {
    UILabel *label = [[UILabel alloc] init];
    [label setText:NUM_RRS];
    [label sizeToFit];
    label.textColor = GRAY_COLOR;
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    self.qtcMeasureRateButton = [[UIBarButtonItem alloc] initWithTitle:MEASURE style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureRR)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];

    NSArray *array = [NSArray arrayWithObjects:labelBarButtonItem,
                      self.qtcMeasureRateButton,
                      cancelButton, nil];
    self.qtcStep1MenuItems = [self spaceoutToolbar:array];
}

- (void)createQTcStep2Toolbar {
    UILabel *label = [[UILabel alloc] init];
    [label setText:QT];
    [label sizeToFit];
    label.textColor = GRAY_COLOR;
    UIBarButtonItem *labelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    self.qtcMeasureQTcButton = [[UIBarButtonItem alloc] initWithTitle:MEASURE style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureQT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];

    NSArray *array = [NSArray arrayWithObjects:labelBarButtonItem,
                      self.qtcMeasureQTcButton,
                      cancelButton, nil];
    self.qtcStep2MenuItems = [self spaceoutToolbar:array];
}

- (void)createMovementToolbar {
    self.leftButton = [[UIBarButtonItem alloc] initWithTitle:LEFT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveLeft)];
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveRight)];

    self.upButton = [[UIBarButtonItem alloc] initWithTitle:UP_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveUp)];
    self.downButton = [[UIBarButtonItem alloc] initWithTitle:DOWN_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(moveDown)];
    self.microLeftButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_LEFT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveLeft)];
    self.microRightButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_RIGHT_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveRight)];
    self.microUpButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_UP_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveUp)];
    self.microDownButton = [[UIBarButtonItem alloc] initWithTitle:MICRO_DOWN_ARROW style:UIBarButtonItemStylePlain target:self action:@selector(microMoveDown)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTweaking)];
    NSArray *array = [NSArray arrayWithObjects:self.leftButton, self.upButton, self.rightButton, self.downButton, self.microLeftButton, self.microUpButton, self.microRightButton, self.microDownButton, doneButton, nil];
    self.movementMenuItems = [self spaceoutToolbar:array];
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
    [self shrinkButtonFontSize:self.movementMenuItems];
    [self shrinkButtonFontSize:self.rotateImageMenuItems];
    if ([self usingRussian]) {
        [self greatlyShrinkButtonFontSize:self.movementMenuItems];
        [self greatlyShrinkButtonFontSize:self.rotateImageMenuItems];
        [self slightlyShrinkButtonFontSize:self.moreMenuItems];
        [self slightlyShrinkButtonFontSize:self.colorMenuItems];
        [self slightlyShrinkButtonFontSize:self.tweakMenuItems];
        [self slightlyShrinkButtonFontSize:self.addCalipersMenuItems];
    }
}

- (void)enlargeMenus {
    [self expandButtonFontSize:self.movementMenuItems];
    [self expandButtonFontSize:self.rotateImageMenuItems];
    if ([self usingRussian]) {
        [self expandButtonFontSize:self.moreMenuItems];
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

- (void)toggleIntervalRate {
    if (nil == self.intRateButtonPopTipView && self.showIntRateToolTip) {
        self.intRateButtonPopTipView = [[CMPopTipView alloc] initWithMessage:INT_RATE_TOOLTIP];
        [self setupToolTip:self.intRateButtonPopTipView];
        [self.intRateButtonPopTipView presentPointingAtBarButtonItem:self.toggleIntervalRateButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.intRateButtonPopTipView dismissAnimated:YES];
        self.intRateButtonPopTipView = nil;
        self.showIntRateToolTip = NO;
        [self stillShowingToolTips];
    }
    self.horizontalCalibration.displayRate = ! self.horizontalCalibration.displayRate;
    [self.calipersView setNeedsDisplay];
}

- (void)meanRR {
    if (nil == self.meanRateButtonPopTipView && self.showMeanRateToolTip) {
        self.meanRateButtonPopTipView = [[CMPopTipView alloc] initWithMessage:MEAN_RATE_TOOLTIP];
        [self setupToolTip:self.meanRateButtonPopTipView];
        [self.meanRateButtonPopTipView presentPointingAtBarButtonItem:self.mRRButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.meanRateButtonPopTipView dismissAnimated:YES];
        self.meanRateButtonPopTipView = nil;
        self.showMeanRateToolTip = NO;
        [self stillShowingToolTips];
    }
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
    UIAlertController *calculateMeanRRAlertController = [UIAlertController alertControllerWithTitle:NUMBER_OF_INTERVALS  message:HOW_MANY_INTERVALS preferredStyle:UIAlertControllerStyleAlert];
    [calculateMeanRRAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = THREE;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self selectMainToolbar];
    }];
    UIAlertAction *calculateAction = [UIAlertAction actionWithTitle:CALCULATE style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSArray *textFields = calculateMeanRRAlertController.textFields;
        UITextField *rawTextField = textFields[0];
        int divisor = [rawTextField.text intValue];
        if (divisor > 0) {
            Caliper *c = self.calipersView.activeCaliper;
            if (c == nil) {
                return;
            }
            double intervalResult = fabs(c.intervalResult);
            double meanRR = intervalResult / divisor;
            double meanRate = [c rateResult:meanRR];
            [Alert showSimpleAlertWithTitle:MEAN_INTERVAL_RATE_LABEL  message:[NSString localizedStringWithFormat:MEAN_INTERVAL_RATE_RESULT, meanRR, [c.calibration rawUnits], meanRate] viewController:self];
        }
        else {
            [self showBadValueDialog];
            [self selectMainToolbar];
        }
    }];
    [calculateMeanRRAlertController addAction:cancelAction];
    [calculateMeanRRAlertController addAction:calculateAction];
    [self presentViewController:calculateMeanRRAlertController animated:YES completion:nil];
}

- (void)calculateQTc {
    if (nil == self.calculateQTcPopTipView && self.showCalculateQTcToolTip) {
        self.calculateQTcPopTipView = [[CMPopTipView alloc] initWithMessage:QTC_TOOLTIP];
        [self setupToolTip:self.calculateQTcPopTipView];
        [self.calculateQTcPopTipView presentPointingAtBarButtonItem:self.qtcButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.calculateQTcPopTipView dismissAnimated:YES];
        self.calculateQTcPopTipView = nil;
        self.showCalculateQTcToolTip = NO;
        [self stillShowingToolTips];
    }
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
        self.inRRForQTc = YES;
    }
}

- (void)qtcMeasureRR {
    if (nil == self.qtcStep1ButtonPopTipView && self.showQtcStep1ToolTip) {
        self.qtcStep1ButtonPopTipView = [[CMPopTipView alloc] initWithMessage:QTC_STEP_1_TOOLTIP];
        [self setupToolTip:self.qtcStep1ButtonPopTipView];
        [self.qtcStep1ButtonPopTipView presentPointingAtBarButtonItem:self.qtcMeasureRateButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.qtcStep1ButtonPopTipView dismissAnimated:YES];
        self.qtcStep1ButtonPopTipView = nil;
        self.showQtcStep1ToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        UIAlertController *calculateMeanRRAlertController = [UIAlertController alertControllerWithTitle:NUMBER_OF_INTERVALS message:HOW_MANY_INTERVALS preferredStyle:UIAlertControllerStyleAlert];
        [calculateMeanRRAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = ONE;
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self selectMainToolbar];
        }];
        UIAlertAction *calculateAction = [UIAlertAction actionWithTitle:CALCULATE style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSArray *textFields = calculateMeanRRAlertController.textFields;
            UITextField *rawTextField = textFields[0];
            int divisor = [rawTextField.text intValue];
            if (divisor > 0) {
                Caliper *c = self.calipersView.activeCaliper;
                if (c == nil) {
                    return;
                }
                double intervalResult = fabs(c.intervalResult);
                double meanRR = intervalResult / divisor;
                self.rrIntervalForQTc = [c intervalInSecs:meanRR];
                self.toolbarItems = self.qtcStep2MenuItems;
                self.inQtc = YES;
                self.inRRForQTc = NO;
            }
            else {
                [self showBadValueDialog];
                [self selectMainToolbar];
            }
        }];
        [calculateMeanRRAlertController addAction:cancelAction];
        [calculateMeanRRAlertController addAction:calculateAction];
        [self presentViewController:calculateMeanRRAlertController animated:YES completion:nil];

    }
}

- (void)qtcMeasureQT {
    if (nil == self.qtcStep2ButtonPopTipView && self.showQtcStep2ToolTip) {
        self.qtcStep2ButtonPopTipView = [[CMPopTipView alloc] initWithMessage:QTC_STEP_2_TOOLTIP];
        [self setupToolTip:self.qtcStep2ButtonPopTipView];
        [self.qtcStep2ButtonPopTipView presentPointingAtBarButtonItem:self.qtcMeasureQTcButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.qtcStep2ButtonPopTipView dismissAnimated:YES];
        self.qtcStep1ButtonPopTipView = nil;
        self.showQtcStep2ToolTip = NO;
        [self stillShowingToolTips];
    }
    if ([self noTimeCaliperSelected]) {
        [self showNoTimeCaliperSelectedAlertView];
    }
    else {
        Caliper *c = [self.calipersView activeCaliper];
        float qt = fabs([c intervalInSecs:c.intervalResult]);
        float meanRR = fabs(self.rrIntervalForQTc);  // already in secs
        MiniQTcResult *qtcResult = [[MiniQTcResult alloc] init];
        NSString *result = [qtcResult calculateFromQtInSec:qt rrInSec:meanRR formula:self.settings.qtcFormula convertToMsec:c.calibration.unitsAreMsec units:c.calibration.units];
        UIAlertController *qtcResultAlertController = [UIAlertController alertControllerWithTitle:CALCULATED_QTC message:result preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:DONE style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self selectMainToolbar];
        }];
        UIAlertAction *repeatQtcAction = [UIAlertAction actionWithTitle:REPEAT_QT style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert) {
            self.toolbarItems = self.qtcStep2MenuItems;
        }];
        [qtcResultAlertController addAction:cancelAlertAction];
        [qtcResultAlertController addAction:repeatQtcAction];
        [self presentViewController:qtcResultAlertController animated:YES completion:nil];
    }
}

// this is not used in current version, and in a future version might be modified to provide
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
        [Alert showSimpleAlertWithTitle:NO_ANGLE_CALIPER_SELECTED message:SELECT_ANGLE_CALIPER  viewController:self];
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
    NSString *riskStatement = LOW_BRUGADA_RISK;
    if (amplitudeCalibratedInMM && timeCalibratedInMsec) {
        // calculate length of triangle base 5 mm away from apex of angle
        double pointsPerMM = 1.0 / self.verticalCalibration.multiplier;
        double pointsPerMsec = 1.0 / self.horizontalCalibration.multiplier;
        double base = [AngleCaliper calculateBaseFromHeight:5 * pointsPerMM andAngle1:c.angleBar1 andAngle2:c.angleBar2];
        double baseInMM = base / pointsPerMM;
        base /= pointsPerMsec;
        calibrationStatement = [NSString stringWithFormat:BRUGADA_BASE_MEASUREMENT, base];
        double riskV1 = [AngleCaliper brugadaRiskV1ForBetaAngle:angleInRadians andBase:baseInMM];
        double riskV2 = [AngleCaliper brugadaRiskV2ForBetaAngle:angleInRadians andBase:baseInMM];
        riskStatement = [NSString stringWithFormat:BRUGADA_RISK_STATEMENT, riskV1, riskV2];
    }
    else {
        calibrationStatement = BRUGADA_CALIBRATION_STATEMENT;
    }
    //    if (angleInDegrees > 58.0) {
    //        riskStatement = BRUGADA_INCREASED_RISK;
    //    }
    NSString *message = [NSString stringWithFormat:BRUGADA_BETA_ANGLE, angleInDegrees, calibrationStatement, riskStatement];
    [Alert showSimpleAlertWithTitle:BRUGADA_RESULTS_TITLE message:message viewController:self];
}

- (BOOL)noTimeCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected]  || [self.calipersView activeCaliper].direction == Vertical) || [[self.calipersView activeCaliper] isAngleCaliper];
}

- (BOOL)noAngleCaliperSelected {
    return (self.calipersView.calipers.count < 1 || [self.calipersView noCaliperIsSelected] || ![[self.calipersView activeCaliper] isAngleCaliper]);

}

- (void)showNoTimeCaliperSelectedAlertView {
    [Alert showSimpleAlertWithTitle:NO_TIME_CALIPER_SELECTED_MESSAGE message:SELECT_TIME_CALIPER_MESSAGE viewController:self];
}

- (void)clearCalibration {
    if (nil == self.clearCalibrationButtonPopTipView && self.showClearCalibrationToolTip) {
        self.clearCalibrationButtonPopTipView = [[CMPopTipView alloc] initWithMessage:CLEAR_CALIBRATION_TOOLTIP];
        [self setupToolTip:self.clearCalibrationButtonPopTipView];
        [self.clearCalibrationButtonPopTipView presentPointingAtBarButtonItem:self.clearButton animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.clearCalibrationButtonPopTipView dismissAnimated:YES];
        self.clearCalibrationButtonPopTipView = nil;
        self.showClearCalibrationToolTip = NO;
        [self stillShowingToolTips];
    }
    [self resetCalibration];
    [self.calipersView setNeedsDisplay];
}


- (void)setupCalibration {
    if (nil == self.setupCalibrationButtonPopTipView && self.showSetupCalibrationToolTip) {
        self.setupCalibrationButtonPopTipView = [[CMPopTipView alloc] initWithMessage:SETUP_CALIBRATION_TOOLTIP];
        [self setupToolTip:self.setupCalibrationButtonPopTipView];
        [self.setupCalibrationButtonPopTipView presentPointingAtBarButtonItem:self.calibrateCalipersButton  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.setupCalibrationButtonPopTipView dismissAnimated:YES];
        self.setupCalibrationButtonPopTipView = nil;
        self.showSetupCalibrationToolTip = NO;
    }
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
    }
    else {
        self.toolbarItems = self.calibrateMenuItems;
        [self.calipersView selectCaliperIfNoneSelected];
    }
}

- (void)setCalibration {
    if (nil == self.setCalibrationButtonPopTipView && self.showSetCalibrationToolTip) {
        self.setCalibrationButtonPopTipView = [[CMPopTipView alloc] initWithMessage:SET_CALIBRATION_TOOLTIP];
        [self setupToolTip:self.setCalibrationButtonPopTipView];
        [self.setCalibrationButtonPopTipView presentPointingAtBarButtonItem:self.setButton  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.setCalibrationButtonPopTipView dismissAnimated:YES];
        self.setCalibrationButtonPopTipView = nil;
        self.showSetCalibrationToolTip = NO;
    }
    if ([self.calipersView noCaliperIsSelected]) {
        [Alert showSimpleAlertWithTitle:NO_CALIPER_SELECTED_MESSAGE message:CALIBRATION_INSTRUCTIONS viewController:self];
        return;
    }
    Caliper* c = self.calipersView.activeCaliper;
    // c should not be nil by this point, but let's just back off if it is here to avoid future nil checks.
    if (c == nil) {
        return;
    }
    // Angle calipers don't require calibration
    if (![c requiresCalibration]) {
        [Alert showSimpleAlertWithTitle:ANGLE_CALIPER message:DO_NOT_CALIBRATE_ANGLE_CALIPERS viewController:self];
        return;
    }
    if (c.valueInPoints <= 0) {
        [Alert showSimpleAlertWithTitle:NEGATIVE_CALIPER message:NEGATIVE_CALIPER_MESSAGE viewController:self];
        return;
    }
    NSString *example = @"";
    if (c.direction == Vertical) {
        example = AMPLITUDE_CAL_EXAMPLE;
    }
    else {
        example = TIME_CAL_EXAMPLE;
    }
    NSString *message = [NSString stringWithFormat:ENTER_MEASUREMENT, example];
    // see https://stackoverflow.com/questions/33996443/how-to-add-text-input-in-alertview-of-ios-8 for using text fields with UIAlertController.
    UIAlertController *calibrationAlertController = [UIAlertController alertControllerWithTitle:CALIBRATE message:message preferredStyle:UIAlertControllerStyleAlert];
    [calibrationAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        NSString *calibrationString = @"";
        // set initial calibration time calibration to default
        if ([self.horizontalCalibration.calibrationString length] < 1 || self.defaultHorizontalCalChanged) {
            self.horizontalCalibration.calibrationString = self.settings.defaultCalibration;
        }
        if ([self.verticalCalibration.calibrationString length] < 1 || self.defaultVerticalCalChanged) {
            self.verticalCalibration.calibrationString = self.settings.defaultVerticalCalibration;
        }
        CaliperDirection direction = c.direction;
        if (direction == Horizontal) {
            calibrationString = self.horizontalCalibration.calibrationString;
        }
        else {
            calibrationString = self.verticalCalibration.calibrationString;
        }
        textField.text = calibrationString;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:SET style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *textFields = calibrationAlertController.textFields;
        UITextField *rawTextField = textFields[0];
        NSString *rawText = rawTextField.text;
        Validation *validation = [CalibrationProcessor validate:rawText direction:c.direction];
        os_log(OS_LOG_DEFAULT, "showWarningDialogs = %d", self->_settings.showWarningDialogs);
        if ([validation isValid]) {
            [self calibrateWithValidation:validation];
        }
        else if ([validation evilInput]) {
            [self showBadValueDialog];
        }
        else if (self.settings.showWarningDialogs && (validation.noUnits || (validation.invalidUnits && c.direction == Horizontal))) {
            NSString *message = validation.noUnits ? NO_UNITS_WARNING : BAD_UNITS_WARNING;
            UIAlertController *calibrateWithBadUnitsAlert = [UIAlertController alertControllerWithTitle:BAD_UNITS message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelCalibrationAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *calibrateAnywayAction = [UIAlertAction actionWithTitle:CALIBRATE_ANYWAY style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self calibrateWithValidation:validation];
            }];
            [calibrateWithBadUnitsAlert addAction:cancelCalibrationAction];
            [calibrateWithBadUnitsAlert addAction:calibrateAnywayAction];
            [self presentViewController:calibrateWithBadUnitsAlert animated:YES completion:nil];
        }
        else {
            [self calibrateWithValidation:validation];
        }
    }];
    [calibrationAlertController addAction:cancelAction];
    [calibrationAlertController addAction:setAction];
    [self presentViewController:calibrationAlertController animated:YES completion:nil];
}

- (void)showNoCalipersAlert {
    [Alert showSimpleAlertWithTitle:NO_CALIPERS_TO_USE message:ADD_SOME_CALIPERS viewController:self];
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
- (void)selectPDFToolbar {
    self.toolbarItems = self.pdfMenuItems;
}

- (void)doneTweaking {
    self.tweakingInProgress = NO;
    [self.calipersView clearAllChosenComponents];
    [self.calipersView setNeedsDisplay];
    if (self.inQtc) {
        self.toolbarItems = self.qtcStep2MenuItems;
    }
    else if (self.inRRForQTc) {
        self.toolbarItems = self.qtcStep1MenuItems;
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
    self.calipersView.allowTweakPosition = NO;
    self.inQtc = NO;
    self.inRRForQTc = NO;
    self.chosenCaliper = nil;
    self.chosenCaliperComponent = None;
    [self.calipersView clearAllChosenComponents];
    [self.calipersView setNeedsDisplay];
}

- (void)selectRotateImageToolbar {
    self.toolbarItems = self.rotateImageMenuItems;
}

- (void)selectCalibrateToolbar {
    self.toolbarItems = self.calibrateMenuItems;
}

- (void)selectColorToolbar {
    self.toolbarItems = self.colorMenuItems;
}

- (void)selectMovementToolbar {
    self.toolbarItems = self.movementMenuItems;
}

- (void)openSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

- (void)checkCameraPermissions {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
            // Note cases must be enclosed in a block to avoid compiler error.  Compiler bug?
            // See https://stackoverflow.com/questions/33550588/defining-a-block-in-a-switch-statement-results-in-a-compiler-error
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleTakePhoto];
                    });
                }
            }];
            return;
        }
        case AVAuthorizationStatusRestricted: {
            EPSLog(@"camera permission restricted");
            return;
        }
        case AVAuthorizationStatusDenied: {
            EPSLog(@"camera permission denied");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:CAMERA_PERMISSION_DENIED_TITLE message:CAMERA_PERMISSION_DENIED_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        case AVAuthorizationStatusAuthorized: {
            EPSLog(@"camera authorized");
            [self handleTakePhoto];
            return;
        }
    }
}

- (void)takePhoto {
    EPSLog(@"Take photo");
    [self checkCameraPermissions];
}

- (void)handleTakePhoto {
    EPSLog(@"Handle take photo");

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [Alert showSimpleAlertWithTitle:CAMERA_NOT_AVAILABLE_TITLE message:CAMERA_NOT_AVAILABLE_MESSAGE viewController:self];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;

    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectImage {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [Alert showSimpleAlertWithTitle:PHOTO_LIBRARY_NOT_AVAILABLE_TITLE message:PHOTO_LIBRARY_NOT_AVAILABLE_MESSAGE viewController:self];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([self isIpad]) {
        // Need to present as popover on iPad
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectFile {
    if (@available(iOS 14.0, *)) {
        NSArray<UTType *> *contentTypes = @[[UTType typeWithIdentifier:UTTypeImage.identifier], [UTType typeWithIdentifier:UTTypePDF.identifier]];
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:contentTypes asCopy:YES];
        picker.delegate = self;
        if ([self isIpad]) {
            picker.modalPresentationStyle = UIModalPresentationPopover;
            picker.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSURL *url = [NSURL fileURLWithPath:documentsPath];
        picker.directoryURL = url;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    [self openURL:urls[0]];
}

- (void)selectImageSource {
    if (@available(iOS 14, *)) {
        UIAlertController *chooser = [UIAlertController alertControllerWithTitle:IMAGE_SOURCE message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        chooser.modalPresentationStyle = UIModalPresentationPopover;
        chooser.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        UIAlertAction *photosAction = [UIAlertAction actionWithTitle:PHOTOS_SOURCE style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self selectImage];
        }];
        UIAlertAction *filesAction = [UIAlertAction actionWithTitle:FILES_SOURCE style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self selectFile];
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:nil];
        [chooser addAction:photosAction];
        [chooser addAction:filesAction];
        [chooser addAction:cancelAction];
        [self presentViewController:chooser animated:YES completion:nil];
    } else {
        [self selectImage];
    }
}

- (void)clearPDF {
    self.numberOfPages = 0;
    // when opening new image or PDF, clear out any old PDF
    if (pdfRef != NULL) {
        CGPDFDocumentRelease(pdfRef);
        pdfRef = NULL;
    }
}

- (void)openURL:(NSURL *)url {
    EPSLog(@"OpenURL");
    [self resetImage:self];
    NSString *extension = [url.pathExtension uppercaseString];
    if (![extension isEqualToString:@"PDF"]) {
        [self enablePageButtons:NO];
        self.imageIsUpscaled = NO;
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
    [self clearCanvasView];
    [self selectMainToolbar];
}

- (void)loadDefaultImage {
    [self clearPDF];
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

- (void)gotoPage {
    // show goto page dialog here
    EPSLog(@"Goto page selected");
    UIAlertController *gotoPageAlertController = [UIAlertController alertControllerWithTitle:GO_TO_PAGE message:nil preferredStyle:UIAlertControllerStyleAlert];
    [gotoPageAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        NSString *stringCurrentPage = [NSString stringWithFormat:@"%i", self.pageNumber];
        textField.text = stringCurrentPage;
        //        // This preselects the text, since probably user will want to change pages.
        //        [textField selectAll:nil];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self selectPDFToolbar];
    }];
    UIAlertAction *gotoAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSArray *textFields = gotoPageAlertController.textFields;
        UITextField *rawTextField = textFields[0];
        int page = [rawTextField.text intValue];
        if (page > self.numberOfPages) {
            page = self.numberOfPages;
        }
        if (page < 1) {
            page = 1;
        }
        self.pageNumber = page;
        [self enablePageButtons:YES];
        [self openPDFPage:self->pdfRef atPage:self.pageNumber];
        [self clearCanvasView];
    }];
    [gotoPageAlertController addAction:cancelAction];
    [gotoPageAlertController addAction:gotoAction];
    [self presentViewController:gotoPageAlertController animated:YES completion:^{
        // Preselect page number, making it easier to change it.
        [gotoPageAlertController.textFields[0] selectAll:nil];
    }];
}

- (void)gotoPreviousPage {
    self.pageNumber--;
    if (self.pageNumber < 1) {
        self.pageNumber = 1;
    }
    [self enablePageButtons:YES];
    [self openPDFPage:pdfRef atPage:self.pageNumber];
    [self clearCanvasView];
}

- (void)gotoNextPage {
    self.pageNumber++;
    if (self.pageNumber > self.numberOfPages) {
        self.pageNumber = self.numberOfPages;
    }
    [self enablePageButtons:YES];
    [self openPDFPage:pdfRef atPage:self.pageNumber];
    [self clearCanvasView];
}

- (void)openPDFPage:(CGPDFDocumentRef) documentRef atPage:(int) pageNum {
    EPSLog(@"openPDFPage");
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
    CGFloat scaleFactor = PDF_UPSCALE_FACTOR;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sourceRect.size.width, sourceRect.size.height), false, scaleFactor);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // Ensure transparent PDFs have white background in dark mode.
    CGContextSetFillColorWithColor(currentContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(currentContext, sourceRect);
    CGContextTranslateCTM(currentContext, 0.0, sourceRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextDrawPDFPage(currentContext, page);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // first scale as usual, but image still too large since scaled up when created for better quality
    image = [self scaleImageForImageView:image];
    // now correct for scale factor when creating image
    image = [UIImage imageWithCGImage:(CGImageRef)image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
    self.imageView.image = image;
    self.imageIsUpscaled = YES;
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
    caliper.textPosition = self.settings.timeTextPosition;
    caliper.calibration = self.horizontalCalibration;
    caliper.verticalCalibration = self.verticalCalibration;
    [caliper setInitialPositionInRect:self.calipersView.bounds];
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
}

- (void)updateCaliperSettings:(Caliper *)caliper {
    caliper.lineWidth = self.settings.lineWidth;
    caliper.unselectedColor = self.settings.caliperColor;
    caliper.selectedColor = self.settings.highlightColor;
    caliper.roundMsecRate = self.settings.roundMsecRate;
    caliper.autoPositionText = self.settings.autoPositionText;
}

- (void)addCaliperWithDirection:(CaliperDirection)direction {
    Caliper *caliper = [CaliperFactory createCaliper:Interval];
    [self updateCaliperSettings:caliper];
    caliper.color = caliper.unselectedColor;
    caliper.direction = direction;
    if (direction == Horizontal) {
        caliper.calibration = self.horizontalCalibration;
        caliper.textPosition = self.settings.timeTextPosition;
    }
    else {
        caliper.calibration = self.verticalCalibration;
        caliper.textPosition = self.settings.amplitudeTextPosition;
    }
    [caliper setInitialPositionInRect:self.calipersView.bounds];

    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
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
        //        self.imageContainerView.transform = CGAffineTransformRotate(self.imageContainerView.transform, radians(degrees));
        //        self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, radians(degrees));
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(degrees));
    }];
}

- (IBAction)resetImage:(id)sender {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        //        self.imageContainerView.transform = CGAffineTransformIdentity;
        //        self.scrollView.transform = CGAffineTransformIdentity;
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
    [self selectMainToolbar];
    [self.calipersView setNeedsDisplay];
}

- (BOOL)isPortraitMode {
    return self.view.frame.size.height > self.view.frame.size.width;
}

- (void)showBadValueDialog {
    [Alert showSimpleAlertWithTitle:BAD_INPUT message:EMPTY_BAD_INPUT viewController:self];
}

// Can only get at this embedded view controller via its segue.
// See https://stackoverflow.com/questions/29582200/how-do-i-get-the-views-inside-a-container-in-swift.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"EmbedSegue"]) {
        self.hamburgerViewController = (HamburgerTableViewController *)segue.destinationViewController;
    }
    if ([segue.identifier isEqualToString:@"showHelpSegue"]) {
        HelpViewController *hvc = (HelpViewController *)segue.destinationViewController;
        hvc.firstStart = self.firstStart;
    }
}

- (void)calibrateWithValidation:(Validation *)validation {
    [self processCalibration:validation.calibrationString trimmedUnits:validation.units value:validation.number];
}

- (void)processCalibration:(NSString *)rawText trimmedUnits:(NSString *)trimmedUnits value:(float)value {
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

#pragma mark - Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self resetImage:self];
    // Images are never upscaled
    self.imageIsUpscaled = NO;
    self.imageView.image = [self scaleImageForImageView:chosenImage];
    // reset zoom for new image
    self.scrollView.zoomScale = 1.0;
    [self.imageView setHidden:NO];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self clearCalibration];
    [self enablePageButtons:NO];
    // remove any prior PDF from memory
    [self clearPDF];
    [self clearCanvasView];
    self.launchURL = nil;
    [self recenterImage];
    [self selectMainToolbar];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)centerContent {
    CGFloat top = 0, left = 0;
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        left = (self.scrollView.bounds.size.width-self.scrollView.contentSize.width) * 0.5f;
    }
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        top = (self.scrollView.bounds.size.height-self.scrollView.contentSize.height) * 0.5f;
    }
    UIEdgeInsets inset = UIEdgeInsetsMake(top, left, top, left);
    self.scrollView.contentInset = inset;
    [self.calipersView setNeedsDisplay];
    if ([self canHaveCanvasView] && self.canvasView != nil
        && self.canvasView.userInteractionEnabled == YES) {
        self.canvasView.contentInset = inset;
        self.canvasView.contentSize = self.scrollView.contentSize;
        self.canvasView.contentOffset = self.scrollView.contentOffset;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.horizontalCalibration.currentZoom = self.scrollView.zoomScale;
    self.verticalCalibration.currentZoom = self.scrollView.zoomScale;
    self.horizontalCalibration.offset = self.scrollView.contentOffset;
    self.verticalCalibration.offset = self.scrollView.contentOffset;
    [self.calipersView setNeedsDisplay];
    [self adjustScrollViews:scrollView];
    [self centerContent];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        return self.imageContainerView;
    } else {
        return nil;
    }
}

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    self.horizontalCalibration.currentZoom = scale;
    self.verticalCalibration.currentZoom = scale;
    self.horizontalCalibration.offset = self.scrollView.contentOffset;
    self.verticalCalibration.offset = self.scrollView.contentOffset;
    [self adjustScrollViews:scrollView];
    [self.calipersView setNeedsDisplay];
    [self centerContent];
}

// This is also called during zooming, so that calipers adjust to zoom and scrolling.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.horizontalCalibration.currentZoom = self.scrollView.zoomScale;
    self.verticalCalibration.currentZoom = self.scrollView.zoomScale;
    self.horizontalCalibration.offset = self.scrollView.contentOffset;
    self.verticalCalibration.offset = self.scrollView.contentOffset;
    [self adjustScrollViews:scrollView];
    [self.calipersView setNeedsDisplay];
    [self centerContent];
}

- (void)adjustScrollViews:(UIScrollView *)scrollView {
    if ([self drivingScrollViewIsCanvasView]) {
        self.scrollView.zoomScale = self.canvasView.zoomScale;
        self.scrollView.contentOffset = self.canvasView.contentOffset;
        [self.calipersView setNeedsDisplay];
        [self.imageView setNeedsDisplay];
    }
}

- (BOOL)drivingScrollViewIsScrollView {
    return ![self drivingScrollViewIsCanvasView];
}

- (BOOL)drivingScrollViewIsCanvasView {
    return ([self canHaveCanvasView] && self.canvasView != nil
            && self.canvasView.userInteractionEnabled == YES);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    EPSLog(@"viewWillTransitionToSize");
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self vitalStats];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self centerContent];
        [self.calipersView setNeedsDisplay];
        [self.imageView setNeedsDisplay];
        [self centerContent];
    });
}

// for debugging
- (void)vitalStats {
    //    EPSLog(@"scrollView zoom = %f", self.scrollView.zoomScale);
    //    EPSLog(@"scrollView offsetX = %f", self.scrollView.contentOffset.x);
    //    EPSLog(@"scrollView offsetY = %f", self.scrollView.contentOffset.y);
    //    EPSLog(@"scrollView contentSizeWidth = %f", self.scrollView.contentSize.width);
    //    EPSLog(@"scrollView contentSizeHeight = %f", self.scrollView.contentSize.height);
    //    EPSLog(@"calipersView frame.size.widht = %f", self.calipersView.frame.size.width);
    //    EPSLog(@"calipersView frame.size.height = %f", self.calipersView.frame.size.height);
    //    EPSLog(@"scrollView frame.size.widht = %f", self.scrollView.frame.size.width);
    //    EPSLog(@"scrollView frame.size.height = %f", self.scrollView.frame.size.height);
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
    // Note that unlock sound (1101, unlock.caf) doesn't do anything anymore,
    // so use the lock sound for both locking and unlocking.
    AudioServicesPlaySystemSoundWithCompletion(1100, nil);
}

- (void)snapshotScreen {
    if (nil == self.snapshotButtonPopTipView && self.showSnapshotButtonToolTip) {
        self.snapshotButtonPopTipView = [[CMPopTipView alloc] initWithMessage:SNAPSHOT_TOOLTIP];
        [self setupToolTip:self.snapshotButtonPopTipView];
        [self.snapshotButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItems[1]  animated:YES];
        return;
    }
    else {
        // Dismiss
        [self.snapshotButtonPopTipView dismissAnimated:YES];
        self.snapshotButtonPopTipView = nil;
        self.showSnapshotButtonToolTip = NO;
    }
    [self checkPhotoLibraryStatus];
}

- (void)handleSnapshotScreen {
    EPSLog(@"snapshot image");
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    UIGraphicsImageRenderer *bottomRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.scrollView.bounds.size format:format];
    CGFloat originX = CGRectGetMinX(self.scrollView.bounds) - self.scrollView.contentOffset.x;
    CGFloat originY = CGRectGetMinY(self.scrollView.bounds) - self.scrollView.contentOffset.y;
    CGRect bounds = CGRectMake(originX, originY, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    UIImage *bottomImage = [bottomRenderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [self.scrollView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    }];
    UIGraphicsImageRenderer *topRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.calipersView.bounds.size format: format];
    UIImage *topImage = [topRenderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [self.calipersView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    }];

    UIImage *canvasImage = nil;
    if (self.canvasView != nil) {
        UIGraphicsImageRenderer *canvasRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.canvasView.bounds.size format: format];
        canvasImage = [canvasRenderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
            [self.canvasView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
        }];
    }

    UIGraphicsBeginImageContext(self.calipersView.bounds.size);
    CGRect bottomRect = CGRectMake(0, 0, self.calipersView.bounds.size.width, self.calipersView.bounds.size.height);
    [bottomImage drawInRect:bottomRect];
    CGRect topRect = CGRectMake(0, 0, self.calipersView.bounds.size.width, self.calipersView.bounds.size.height);
    [topImage drawInRect:topRect];

    if (self.canvasView != nil && canvasImage != nil) {
        CGRect canvasRect = CGRectMake(0, 0, self.canvasView.bounds.size.width, self.canvasView.bounds.size.height);
        [canvasImage drawInRect:canvasRect];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (image != nil) {
        ImageSaver *imageSaver = [[ImageSaver alloc] init];
        [imageSaver writeToPhotoAlbumWithImage:image viewController:self];
    }
}

- (void)checkPhotoLibraryStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized: {
            EPSLog(@"Photo library status authorized.");
            [self handleSnapshotScreen];
            break;
        }
        case PHAuthorizationStatusDenied: {
            EPSLog(@"Photo library status denied.");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photo Library Not Authorized By User" message:@"write this message" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        case PHAuthorizationStatusRestricted: {
            EPSLog(@"Photo library status restricted.");
            break;
        }
        case PHAuthorizationStatusNotDetermined: {
            EPSLog(@"Photo library status not determined.");
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleSnapshotScreen];
                    });
                }
            }];
            return;
        }
        case PHAuthorizationStatusLimited:
            EPSLog(@"Photo library status limited.");
            break;
    }
}

- (BOOL)imageIsLocked {
    return self.calipersView.lockImageScreen;
}

#pragma mark - CalipersViewDelegate Methods

// from https://github.com/fcanas/ios-color-picker
- (void)chooseColor:(Caliper *)caliper {
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.backgroundColor = [UIColor systemBackgroundColor];
    self.chosenCaliper = caliper;
    colorPicker.color = caliper.unselectedColor;
    colorPicker.delegate = self;

    [colorPicker setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:colorPicker animated:YES completion:nil];
}

- (void)tweakComponent:(CaliperComponent)component forCaliper:(Caliper *)caliper {
    self.tweakingInProgress = YES;
    self.chosenCaliper = caliper;
    self.chosenCaliperComponent = component;
    caliper.chosenComponent = component;
    [self.calipersView clearChosenComponentsExceptFor:caliper];
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
    [self.calipersView setNeedsDisplay];
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
    [coder encodeObject:self.launchURL forKey:LAUNCH_URL_KEY];
    [coder encodeInteger:self.numberOfPages forKey:NUMBER_OF_PAGES_KEY];
    [coder encodeDouble:(double)self.scrollView.zoomScale forKey:ZOOM_SCALE_KEY];
    [self encodeImage:self.imageView.image withKey:SAVED_IMAGE_STRING_KEY toCoder:coder];
    [coder encodeBool:self.imageIsUpscaled forKey:IMAGE_IS_UPSCALED_KEY];

    // Note that image lock is intentionally not preserved when app goes to background.
    // The reason is that image restoration moves the image location, so the process
    // of going to background itself moves the image.  So it's really not locked in
    // place.

    // calibration
    [self.horizontalCalibration encodeCalibrationState:coder withPrefix:HORIZONATAL_PREFIX_KEY];
    [self.verticalCalibration encodeCalibrationState:coder withPrefix:VERTICAL_PREFIX_KEY];

    // calipers
    [coder encodeInteger:[self.calipersView count] forKey:CALIPERS_COUNT_KEY];
    [coder encodeBool:self.calipersView.aCaliperIsMarching forKey:A_CALIPER_IS_MARCHING_KEY];
    for (int i = 0; i < [self.calipersView count]; i++) {
        [self.calipersView.calipers[i] encodeCaliperState:coder withPrefix:[NSString stringWithFormat:@"%d", i]];
        EPSLog(@"calipers is Angle %d", [self.calipersView.calipers[i] isAngleCaliper]);
    }

    // Canvas view
    // Note that if canvas view is active when app is removed from memory,
    // the app returns with the canvas view toggled off, but the image is
    // still there.
    if ([self canHaveCanvasView] && self.canvasView != nil) {
        PKDrawing *drawing = self.canvasView.drawing;
        if (drawing != nil) {
            [self encodeDrawing:drawing withKey:CANVAS_VIEW_DRAWING_STRING_KEY toCoder:coder];
        }
    }
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    EPSLog(@"decodeRestorableStateWithCoder");
    //self.firstRun = NO;
    self.launchURL = [coder decodeObjectOfClass:[NSURL class] forKey:LAUNCH_URL_KEY]; 
    self.numberOfPages = (int)[coder decodeIntegerForKey:NUMBER_OF_PAGES_KEY];
    UIImage *image = [self decodeImageForKey:SAVED_IMAGE_STRING_KEY fromCoder:coder];
    if (self.launchURL != nil) {
        self.wasLaunchedFromUrl = YES;
        //        image = [UIImage imageWithCGImage:(CGImageRef)image.CGImage scale:PDF_UPSCALE_FACTOR orientation:UIImageOrientationUp];
    }
    self.imageView.image = image;
    self.scrollView.zoomScale = [coder decodeDoubleForKey:ZOOM_SCALE_KEY];
    self.imageIsUpscaled = [coder decodeBoolForKey:IMAGE_IS_UPSCALED_KEY];

    // calibration
    [self.horizontalCalibration decodeCalibrationState:coder withPrefix:HORIZONATAL_PREFIX_KEY];
    [self.verticalCalibration decodeCalibrationState:coder withPrefix:VERTICAL_PREFIX_KEY];
    self.horizontalCalibration.offset = self.scrollView.contentOffset;
    self.verticalCalibration.offset = self.scrollView.contentOffset;

    // calipers
    NSInteger calipersCount = [coder decodeIntegerForKey:CALIPERS_COUNT_KEY];
    self.calipersView.aCaliperIsMarching = [coder decodeBoolForKey:A_CALIPER_IS_MARCHING_KEY];
    for (int i = 0; i < calipersCount; i++) {
        BOOL isAngleCaliper = [coder decodeBoolForKey:[NSString stringWithFormat:IS_ANGLE_CALIPER_FORMAT_KEY, i]];
        CaliperType type = isAngleCaliper ? Angle : Interval;
        Caliper *newCaliper = [CaliperFactory createCaliper:type];
        [newCaliper decodeCaliperState:coder withPrefix:[NSString stringWithFormat:@"%d", i]];
        newCaliper.autoPositionText = self.settings.autoPositionText;
        if (newCaliper.direction == Horizontal) {
            newCaliper.calibration = self.horizontalCalibration;
            newCaliper.textPosition = self.settings.timeTextPosition;
        }
        else {
            newCaliper.calibration = self.verticalCalibration;
            newCaliper.textPosition = self.settings.amplitudeTextPosition;
        }
        if ([newCaliper isAngleCaliper]) {
            ((AngleCaliper *)newCaliper).verticalCalibration = self.verticalCalibration;
        }
        [self.calipersView.calipers addObject:newCaliper];
    }
    [self.calipersView setNeedsDisplay];

    // Canvas view
    // Note that if canvas view is active when app is removed from memory,
    // the app returns with the canvas view toggled off, but the image is
    // still there.
    if ([self canHaveCanvasView] && self.canvasView != nil) {
        PKDrawing *drawing = [self decodeDrawingForKey:CANVAS_VIEW_DRAWING_STRING_KEY fromCoder:coder];
        if (drawing != nil) {
            self.canvasView.drawing = drawing;
            self.canvasView.contentSize = self.scrollView.contentSize;
            self.canvasView.contentOffset = self.scrollView.contentOffset;
            self.canvasView.contentInset = self.scrollView.contentInset;
            self.canvasView.zoomScale = self.scrollView.zoomScale;
        }
    }
    [super decodeRestorableStateWithCoder:coder];
}

- (UIImage *)decodeImageForKey:(NSString *)key fromCoder:(NSCoder *)coder {
    NSString *imageString = [coder decodeObjectOfClass:[NSString class] forKey:key];
    if (imageString != nil) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageString options:0];
        if (imageData != nil) {
            return [[UIImage alloc] initWithData:imageData];
        }
    }
    return nil;
}

- (PKDrawing *)decodeDrawingForKey:(NSString *)key fromCoder:(NSCoder *)coder {
    NSString *drawingString = [coder decodeObjectOfClass:[NSString class] forKey:key];
    if (drawingString != nil) {
        NSData *drawingData = [[NSData alloc] initWithBase64EncodedString:drawingString options:0];
        if (drawingData != nil) {
            return [[PKDrawing alloc] initWithData:drawingData error:nil];
        }
    }
    return nil;
}

- (void)encodeImage:(UIImage *)image withKey:(NSString *)key toCoder:(NSCoder *)coder {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageString = [imageData base64EncodedStringWithOptions:0];
    [coder encodeObject:imageString forKey:key];
}

- (void)encodeDrawing:(PKDrawing *)drawing withKey:(NSString *)key toCoder:(NSCoder *)coder {
    NSData *drawingData = [drawing dataRepresentation];
    NSString *drawingString = [drawingData base64EncodedStringWithOptions:0];
    [coder encodeObject:drawingString forKey: key];
}

@end
