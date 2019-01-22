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
#import "Defs.h"

// These can't be yes for release version
#ifdef DEBUG
// Set to yes to always show startup screen, for testing
#define TEST_QUICK_START YES
// Set to YES to skip introductory tooltips, for testing
#define SKIP_INTRO_TOOLTIPS YES
// Set to YES to show PDF menu regardless of their being a PDF
#define SHOW_PDF_MENU NO
#else
#define TEST_QUICK_START NO
// We are using the quick help images now rather than the intro tooltips,
// so skip them.
#define SKIP_INTRO_TOOLTIPS YES
#define SHOW_PDF_MENU NO
#endif

// Language for localization
#define LANG L(@"lang")

// Minimum press duration for long presses (default = 0.5)
#define MINIMUM_PRESS_DURATION 0.8
#define ANIMATION_DURATION 0.5
#define MAX_ZOOM 10.0
#define MOVEMENT 1.0f
#define MICRO_MOVEMENT 0.1f
#define MAX_BLACKVIEW_ALPHA 0.4f

#define CALIBRATE L(@"Calibrate")
// TODO: Do we need short forms for any language for below?
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

#define LEFT_ARROW @"⇦"
#define RIGHT_ARROW @"⇨"
#define MICRO_LEFT_ARROW @"←"
#define MICRO_RIGHT_ARROW @"→"
#define UP_ARROW @"⇧"
#define DOWN_ARROW @"⇩"
#define MICRO_UP_ARROW @"↑"
#define MICRO_DOWN_ARROW @"↓"

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
#define ONE_MV L(@"One_mv")
#define FIVE_HUNDRED_MSEC L(@"Five_hundred_msec")
#define CAMERA_NOT_AVAILABLE_TITLE L(@"Camera_not_available_title")
#define CAMERA_NOT_AVAILABLE_MESSAGE L(@"Camera_not_available_message")

#define WHITE [UIColor whiteColor]
#define GRAY [UIColor lightGrayColor]

#define VERY_SMALL_FONT 10
#define SMALL_FONT 12
#define INTERMEDIATE_FONT 14

#define CALIPERS_VIEW_TITLE L(@"EP Calipers")

#define IMAGE_TINT [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]

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

// tooltips
// tooltips shown at start
@property (strong, nonatomic) CMPopTipView *navBarLeftButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *navBarRightButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *measurementToolbarPopTipView;
@property (strong, nonatomic) CMPopTipView *caliperPopTipView;
@property (strong, nonatomic) CMPopTipView *imagePopTipView;
@property (strong, nonatomic) CMPopTipView *longPressPopTipView;
// button tooltips
@property (strong, nonatomic) CMPopTipView *addCaliperButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *sideMenuButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *setupCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *setCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *clearCalibrationButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *intRateButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *meanRateButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *calculateQTcPopTipView;
@property (strong, nonatomic) CMPopTipView *qtcStep1ButtonPopTipView;
@property (strong, nonatomic) CMPopTipView *qtcStep2ButtonPopTipView;
// Target views for tooltips
@property (strong, nonatomic) UIView *imageTargetView;
@property (strong, nonatomic) UIView *caliperTargetView;

// don't allow buttons to work while showing first tooltips
@property (nonatomic) BOOL showingInitialTooltips;

@property (nonatomic) BOOL showAddCaliperButtonToolTip;
@property (nonatomic) BOOL showSideMenuButtonToolTip;
@property (nonatomic) BOOL showSetupCalibrationToolTip;
@property (nonatomic) BOOL showSetCalibrationToolTip;
@property (nonatomic) BOOL showClearCalibrationToolTip;
@property (nonatomic) BOOL showIntRateToolTip;
@property (nonatomic) BOOL showMeanRateToolTip;
@property (nonatomic) BOOL showCalculateQTcToolTip;
@property (nonatomic) BOOL showQtcStep1ToolTip;
@property (nonatomic) BOOL showQtcStep2ToolTip;
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
    self.maxBlackAlpha = MAX_BLACKVIEW_ALPHA;

    self.pressLocation = CGPointMake(0, 0);

    self.settings = [[Settings alloc] init];
    [self.settings loadPreferences];

    // fonts
    [self loadFonts];
    
    self.isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    [self createToolbars];

    //self.imageView.delegate = self;
    self.blackView.delegate = self;
    [self.imageView setContentMode:UIViewContentModeCenter];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
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

    // init QTc variables
    self.rrIntervalForQTc = 0.0;
    self.inQtc = NO;

    // After experimentation, white background color seems best.
    self.imageView.backgroundColor = WHITE;
    [self.imageView setHidden:YES];  // hide view until it is rescaled

    // hide hamburger menu
    self.constraintHamburgerLeft.constant = -self.constraintHamburgerWidth.constant;
    self.hamburgerMenuIsOpen = NO;
    self.hamburgerViewController.imageIsLocked = self.calipersView.locked;
    self.blackView.alpha = 0;

    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddCaliperMenu)];
    self.navigationItem.rightBarButtonItem = addCaliperButton;
    // icon from https://icons8.com/icon/set/hamburger/ios
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleHamburgerMenu)];
    [self.navigationItem setTitle:CALIPERS_VIEW_TITLE];

    [self setupTheme];

    self.isCalipersView = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;   // nav & toolbar don't overlap view
    self.firstRun = YES;
    
    self.wasLaunchedFromUrl = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBackToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    UILongPressGestureRecognizer *longPressScrollView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doScrollViewLongPress:)];
    [longPressScrollView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
    [self.scrollView addGestureRecognizer:longPressScrollView];

    UILongPressGestureRecognizer *longPressCalipersView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doCalipersViewLongPress:)];
    [longPressCalipersView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
    [self.calipersView addGestureRecognizer:longPressCalipersView];
}

- (UIImage *)onePixelImageWithColor:(UIColor *)color {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 1, 1, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return image;
}

- (void)setupTheme {
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    if (self.settings.darkTheme) {
        // Note that toolbar background colors don't work.  See
        // https://stackoverflow.com/questions/4996906/uitoolbar-with-reduced-alpha-want-uibarbuttonitem-to-have-alpha-1/26642590#26642590

        // Below uses a white on black color
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        self.navigationController.toolbar.tintColor = WHITE;
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        self.navigationController.navigationBar.tintColor = WHITE;
        // Use this if you want tinted bars.
        // [self.navigationController.toolbar setBackgroundImage:[self onePixelImageWithColor:[barColor colorWithAlphaComponent:0.2]] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
        self.navigationController.toolbar.tintColor = nil;
        self.navigationController.navigationBar.tintColor = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    EPSLog(@"ViewDidAppear");
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    // Sometimes calipers are malpositioned when view restored.
    [self.calipersView setNeedsDisplay];

//    EPSLog(@"Language code using preferredLanguages = %@", [[NSLocale preferredLanguages] firstObject]);
//    EPSLog(@"Language code using localizedStrings = %@", [self applicationLanguage]);

    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setToolbarHidden:NO];

    if (self.firstRun) {
        EPSLog(@"++++++++Rescaling image++++++++++++");
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
            [Alert showSimpleAlertWithTitle:MULTIPAGE_PDF message:MULTIPAGE_PDF_WARNING viewController:self];
            self.launchURL = nil;
            self.numberOfPages = 0;
            self.wasLaunchedFromUrl = NO;
        }
        
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
        [self.imageView setHidden:NO];
        // When starting add a caliper if one isn't there already
        if ([self.calipersView count] == 0) {
            [self addHorizontalCaliper];
        }
        [self selectMainToolbar];
    }
}

- (void)showToolTips {
    // This method is a toggle.  Turn off tool tips if showing them.
    if (self.showingToolTips) {
        [self disableToolTips];
        return;
    }
    [self initToolTips];
    if (!SKIP_INTRO_TOOLTIPS) {
        self.showingInitialTooltips = YES;
        self.caliperPopTipView = [[CMPopTipView alloc] initWithMessage:MOVE_CALIPER_TOOLTIP];
        [self setupToolTip:self.caliperPopTipView];
        [self.caliperPopTipView presentPointingAtView:self.caliperTargetView inView:self.view animated:YES];
    }
}

// TODO: You might change this with future releases.  For example, someone upgrading from 3.0 to 3.1
// wouldn't necessarily want to see the tooltips again post upgrade.  However anyone upgrading from
// version 2.X.Y. would want to see them.  For version 3.0, everyone gets to see the tooltips.
- (BOOL)shouldShowTooltipsAtStart {
    return self.isNewInstallation || self.isUpgrade;
}

- (void)setToolTipState:(BOOL)value {
    self.showAddCaliperButtonToolTip = value;
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

// TODO: update these tooltip settings
- (void)initToolTips {
    [self initToolTipTargets];
    [self setToolTipState:YES];
    [self stillShowingToolTips];
}

- (void)disableToolTips {
    [self setToolTipState:NO];
    [self stillShowingToolTips];
}

- (void)initToolTipTargets {
    self.imageTargetView = [[UIView alloc] init];
    [self.imageTargetView setFrame:CGRectMake(0, 0, 1, 1)];
    self.imageTargetView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    EPSLog(@"Image target center.x = %f, center.y = %f", self.imageTargetView.center.x, self.imageTargetView.center.y);
    [self.view addSubview:self.imageTargetView];
    self.caliperTargetView = [[UIView alloc] init];
    [self.caliperTargetView setFrame:CGRectMake(0, 0, 1, 1)];
    CGPoint caliperCenter = [self.calipersView getATimeCaliperMidpoint];
    if (caliperCenter.x == 0 && caliperCenter.y == 0) { // no time caliper found
        self.caliperTargetView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    }
    else {
        self.caliperTargetView.center = caliperCenter;
        EPSLog(@"Caliper target center.x = %f, center.y = %f", self.caliperTargetView.center.x, self.caliperTargetView.center.y);
    }
    [self.view addSubview:self.caliperTargetView];
}

- (void)removeToolTipTargets {
    [self.imageTargetView removeFromSuperview];
    self.imageTargetView = nil;
    [self.caliperTargetView removeFromSuperview];
    self.caliperTargetView = nil;
}

- (void)stillShowingToolTips {
    BOOL toolTipsRemain = self.showSetupCalibrationToolTip || self.showSetCalibrationToolTip || self.showIntRateToolTip || self.showMeanRateToolTip || self.showClearCalibrationToolTip || self.showQtcStep1ToolTip || self.showQtcStep2ToolTip;
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
    if ([popTipView isEqual:self.caliperPopTipView]) {
        self.caliperPopTipView = nil;
        self.measurementToolbarPopTipView = [[CMPopTipView alloc] initWithMessage:MEASUREMENT_TOOLTIP];
        [self setupToolTip:self.measurementToolbarPopTipView];
        [self.measurementToolbarPopTipView presentPointingAtView:self.navigationController.toolbar inView:self.view animated:YES];
    }

    if ([popTipView isEqual:self.measurementToolbarPopTipView]) {
        self.measurementToolbarPopTipView = nil;
        self.imagePopTipView = [[CMPopTipView alloc] initWithMessage:MOVE_IMAGE_TOOLTIP];
        [self setupToolTip:self.imagePopTipView];
        [self.imagePopTipView presentPointingAtView:self.imageTargetView inView:self.view animated:YES];
    }

    if ([popTipView isEqual:self.imagePopTipView]) {
        self.imagePopTipView = nil;
        self.longPressPopTipView = [[CMPopTipView alloc] initWithMessage:LONGPRESS_TOOLTIP];
        [self setupToolTip:self.longPressPopTipView];
        [self.longPressPopTipView presentPointingAtView:self.caliperTargetView inView:self.view animated:YES];
    }

    // MARK: This must be the last of the mandatory initial tooltips.
    // Turning off showingInitialTooltips allows the buttons to work.
    if ([popTipView isEqual:self.longPressPopTipView]) {
        self.longPressPopTipView = nil;
        self.showingInitialTooltips = NO;
        [self removeToolTipTargets];
    }

    if ([popTipView isEqual:self.addCaliperButtonPopTipView]) {
        self.showAddCaliperButtonToolTip = NO;
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
    UIMenuItem *doneMenuItem = [[UIMenuItem alloc] initWithTitle:DONE action:@selector(doneMenuAction)];
    // Only include march menu if we are on a time caliper.
    if ([self.calipersView caliperNearLocationIsTimeCaliper:location]) {
        menu.menuItems = @[colorMenuItem, tweakMenuItem, marchMenuItem, doneMenuItem];
    }
    else {
        menu.menuItems = @[colorMenuItem, tweakMenuItem, doneMenuItem];
    }
    CGRect rect = CGRectMake(location.x, location.y, 0, 0);
    UIView *superView = sender.view.superview;
    [menu setTargetRect:rect inView:superView];
    [menu setMenuVisible:YES animated:YES];
}

- (void)doScrollViewLongPress:(UILongPressGestureRecognizer *) sender {
    EPSLog(@"Long press from main");
    if (sender.state != UIGestureRecognizerStateBegan || self.hamburgerMenuIsOpen) {
        return;
    }
    [sender.view becomeFirstResponder];
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
    [menu setTargetRect:rect inView:superView];
    [menu setMenuVisible:YES animated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAddCaliperMenu {
    if (self.showingInitialTooltips) {
        return;
    }
    if (nil == self.addCaliperButtonPopTipView && self.showAddCaliperButtonToolTip) {
        self.addCaliperButtonPopTipView = [[CMPopTipView alloc] initWithMessage:ADD_TOOLTIP];
        [self setupToolTip:self.addCaliperButtonPopTipView];
        [self.addCaliperButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem  animated:YES];
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
    if (self.showingInitialTooltips) {
        return;
    }
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
    
}
- (void)showHamburgerMenu {
    [self.hamburgerViewController reloadData];
    self.constraintHamburgerLeft.constant = 0;
    self.hamburgerMenuIsOpen = YES;
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.calipersView setUserInteractionEnabled:NO];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        [self.view layoutIfNeeded];
        self.blackView.alpha = self.maxBlackAlpha;
    }];
}

- (void)hideHamburgerMenu {
    self.constraintHamburgerLeft.constant = -self.constraintHamburgerWidth.constant;
    self.hamburgerMenuIsOpen = NO;
    [self.calipersView setUserInteractionEnabled:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
        [self.view layoutIfNeeded];
        self.blackView.alpha = 0;
    }];
}

- (void)showHelp {
    [self performSegueWithIdentifier:@"showHelpSegue" sender:self];
//    [self performSegueWithIdentifier:@"showHelpImageSegue" sender:self];
//    [self performSegueWithIdentifier:@"WebViewSegue" sender:self];
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
    label.textColor = GRAY;
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
    label.textColor = GRAY;
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
    if (self.showingInitialTooltips) {
        return;
    }
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
    if (self.showingInitialTooltips) {
        return;
    }
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
    if (self.showingInitialTooltips) {
        return;
    }
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
        self.calipersView.locked = YES;
    }
}

- (void)qtcMeasureRR {
    if (self.showingInitialTooltips) {
        return;
    }
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
    if (self.showingInitialTooltips) {
        return;
    }
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
    if (self.showingInitialTooltips) {
        return;
    }
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
    // Toggle popTipView when a standard UIButton is pressed
    if (self.showingInitialTooltips) {
        return;
    }
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
        self.calipersView.locked = NO;
    }
}

- (void)setCalibration {
    if (self.showingInitialTooltips) {
        return;
    }
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
    if (c!= nil && c.direction == Vertical) {
        example = ONE_MV;
    }
    else {
        example = FIVE_HUNDRED_MSEC;
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
        if (c != nil) {
            CaliperDirection direction = c.direction;
            if (direction == Horizontal) {
                calibrationString = self.horizontalCalibration.calibrationString;
            }
            else {
                calibrationString = self.verticalCalibration.calibrationString;
            }
        }
        textField.text = calibrationString;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:SET style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *textFields = calibrationAlertController.textFields;
        UITextField *rawTextField = textFields[0];
        NSString *rawText = rawTextField.text;
        if (rawText.length > 0) {
            [self calibrateWithText:rawText];
        }
        else {
            [self showBadValueDialog];
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
    self.calipersView.allowTweakPosition = NO;
    self.inQtc = NO;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)takePhoto {
    EPSLog(@"Take photo");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (self.isIpad) {
        picker.allowsEditing = NO;
    }
    else {
        picker.allowsEditing = YES;
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [Alert showSimpleAlertWithTitle:CAMERA_NOT_AVAILABLE_TITLE message:CAMERA_NOT_AVAILABLE_MESSAGE viewController:self];
        return;
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
    EPSLog(@"OpenURL");
    [self resetImage:self];
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
    caliper.textPosition = self.settings.timeTextPosition;
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

#pragma mark - Delegate Methods

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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = nil;
    // UIImagePickerController broken on iOS 9, iPad only http://openradar.appspot.com/radar?id=5032957332946944
    if (self.isIpad) {
        chosenImage = info[UIImagePickerControllerOriginalImage];
    }
    else {
        chosenImage = info[UIImagePickerControllerEditedImage];
        }
    [self resetImage:self];
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
    [self selectMainToolbar];
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
    EPSLog(@"viewWillTransitionToSize");
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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

- (BOOL)imageIsLocked {
    return self.calipersView.lockImageScreen;
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
    [coder encodeObject:self.launchURL forKey:@"LaunchURL"];
    [coder encodeInteger:self.numberOfPages forKey:@"NumberOfPages"];
    [coder encodeObject:UIImagePNGRepresentation(self.imageView.image)
                 forKey:@"SavedImageKey"];
    [coder encodeDouble:(double)self.scrollView.zoomScale forKey:@"ZoomScaleKey"];

    // Note that image lock is intentionally not preserved when app goes to background.
    // The reason is that image restoration moves the image location, so the process
    // of going to background itself moves the image.  So it's really not locked in
    // place.

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
    [super decodeRestorableStateWithCoder:coder];
}

@end

