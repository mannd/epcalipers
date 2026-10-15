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
#define MEASURE_RR L(@"Measure_RR")
#define MEASURE_QT L(@"Measure_QT")
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

@interface EPSMainViewController () <UIEditMenuInteractionDelegate>

@property (strong, nonatomic) UIFont *verySmallFont;
@property (strong, nonatomic) NSDictionary *verySmallFontAttributes;
@property (strong, nonatomic) UIFont *smallFont;
@property (strong, nonatomic) NSDictionary *smallFontAttributes;
@property (strong, nonatomic) UIFont *intermediateFont;
@property (strong, nonatomic) NSDictionary *intermediateFontAttributes;
@property (strong, nonatomic) UIFont *regularFont;
@property (strong, nonatomic) NSDictionary *regularFontAttributes;
@property (nonatomic) CGPoint pressLocation;
@property (strong, nonatomic) UIEditMenuInteraction *calipersEditMenuInteraction;
@property (strong, nonatomic) UIEditMenuInteraction *scrollEditMenuInteraction;


@property (nonatomic) CGAffineTransform imageTransform;
@property (nonatomic) BOOL imageIsUpscaled;

@property (nonatomic, strong) UIView *mainActionBar;
@property (nonatomic, strong) NSArray<UIButton *> *mainActionButtons;
@property (nonatomic) BOOL mainActionBarSelected;
@property (nonatomic) BOOL bottomControlsHidden;
@property (nonatomic) CGFloat mainActionBarInset;

@property (nonatomic, strong) UISegmentedControl *movementSegmentedControl;
@property (nonatomic, strong) UISegmentedControl *rotateSegmentedControl;

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

- (void)viewIsAppearing:(BOOL)animated {
    [super viewIsAppearing:animated];
    // Registration handles later changes; initialize menus once traits are established.
    [self updateMenusForSizeClass];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"viewDidLoad");

    [self registerForTraitChanges:@[
        [UITraitHorizontalSizeClass class],
        [UITraitVerticalSizeClass class],
        [UITraitPreferredContentSizeCategory class]
    ] withAction:@selector(updateMenusForSizeClass)];

    // TODO: Change
    //    self.view.backgroundColor = [UIColor clearColor];

    if (@available(iOS 26.0, *)) {
        UIContextMenuInteraction *calipersInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
        [self.calipersView addInteraction:calipersInteraction];
        
        UIContextMenuInteraction *scrollInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
        [self.scrollView addInteraction:scrollInteraction];
    } else {
        // Edit menus preserve the existing long-press gestures without context-menu previews.
        self.calipersEditMenuInteraction = [[UIEditMenuInteraction alloc] initWithDelegate:self];
        [self.calipersView addInteraction:self.calipersEditMenuInteraction];
        self.scrollEditMenuInteraction = [[UIEditMenuInteraction alloc] initWithDelegate:self];
        [self.scrollView addInteraction:self.scrollEditMenuInteraction];

        // Touches
        UILongPressGestureRecognizer *longPressScrollView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doScrollViewLongPress:)];
        [longPressScrollView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
        [self.scrollView addGestureRecognizer:longPressScrollView];

        UILongPressGestureRecognizer *longPressCalipersView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doCalipersViewLongPress:)];
        [longPressCalipersView setMinimumPressDuration:MINIMUM_PRESS_DURATION];
        [self.calipersView addGestureRecognizer:longPressCalipersView];
    }
    
    [self createCanvasView];

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

    // NB: This line was deleted for iOS toolbar to work correctly in iOS 26,
    // and it doesn't seem necessary for earlier iOS either.
    //self.edgesForExtendedLayout = UIRectEdgeNone;   // nav & toolbar don't overlap view

    self.firstRun = YES;
    self.wasLaunchedFromUrl = NO;

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBackToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

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
    NSLog(@"Setting up theme");
    [self setupNavigationBar];
    if (@available(iOS 26.0, *)) {
        // Leave toolbar alone in iOS 26, to allow liquid glass to work.
    } else {
        [self setupToolbar];
    }
}

- (void)setupNavigationBar {
    self.navigationController.navigationBar.translucent = NO;

    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];

    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navigationBarAppearance configureWithTransparentBackground];
    navigationBarAppearance.backgroundColor = [UIColor systemBackgroundColor]; // Explicitly clear

    self.navigationController.navigationBar.standardAppearance = navigationBarAppearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;

    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}


- (void)setupToolbar {
    NSLog(@"setupToolbar****");
    self.navigationController.toolbar.translucent = NO;

    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];

    UIToolbarAppearance *toolbarAppearance = [[UIToolbarAppearance alloc] init];
    [toolbarAppearance configureWithOpaqueBackground];
    toolbarAppearance.backgroundColor = [UIColor systemBackgroundColor];

    self.navigationController.toolbar.standardAppearance = toolbarAppearance;
    if (@available(iOS 15.0, *)) {
        self.navigationController.toolbar.scrollEdgeAppearance = toolbarAppearance;
    } else {
        // Fallback on earlier versions
    }

    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
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
    [self setBottomControlsHidden:NO animated:YES];

    if (self.firstRun) {
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

        if (TEST_QUICK_START || [self shouldShowQuickStartAtStart]) {
            self.firstStart = YES;
            [self showHelp];
            self.firstStart = NO;
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
        [self setBottomControlsHidden:NO animated:NO];
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
        [self setBottomControlsHidden:YES animated:NO];
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

- (BOOL)shouldShowQuickStartAtStart {
    EPSLog(@"Previous app version = %@", self.priorVersion);
    EPSLog(@"Current app version = %@", self.currentVersion);
    EPSLog(@"Previous app major version = %@", self.priorMajorVersion);
    if (self.isNewInstallation) {
        return YES;
    }
    // Only show Quick Start at startup if upgrade is from version 1 or 2
    if (self.isUpgrade && (self.priorMajorVersion == nil || [self.priorMajorVersion  isEqual: @"1"] || [self.priorMajorVersion  isEqual: @"2"])) {
        return YES;
    }
    return NO;
}

- (NSString *)applicationLanguage {
    return LANG;
}

// Have to adjust font sizes for Russian, so need to know what language we are using.
- (BOOL)usingRussian {
    return [[self applicationLanguage] isEqualToString:@"ru"];
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
    if (self.hamburgerMenuIsOpen) {
        [self hideHamburgerMenu];
    }
    else {
        [self showHamburgerMenu];
    }
    [self.calipersView setNeedsDisplay];
}

- (void)showHamburgerMenu {
    [self setBottomControlsHidden:YES animated:NO];
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
    [self setBottomControlsHidden:NO animated:NO];
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
    [self createRotateImageToolbar];
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
    [self createMainActionBar];
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

- (void)createRotateImageToolbar {
    NSArray *items = @[ROTATE_90_R, ROTATE_90_L, ROTATE_1_R, ROTATE_1_L, ROTATE_01_R, ROTATE_01_L];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    [segmentedControl addTarget:self action:@selector(rotateSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.rotateSegmentedControl = segmentedControl; // Optional: keep a reference if needed

    // The wrapper is resized to leave room for Done on modern toolbars.
    UIView *controlWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    segmentedControl.frame = controlWrapper.bounds;
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [controlWrapper addSubview:segmentedControl];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:controlWrapper];
    if (@available(iOS 26.0, *)) {
        segmentedItem.hidesSharedBackground = YES;
    }
    if (@available(iOS 27.0, *)) {
        segmentedItem.paddingRemoved = YES;
    }

    // A custom view cannot supply its segment actions to the overflow menu automatically.
    NSArray<NSNumber *> *angles = @[@90, @(-90), @1, @(-1), @0.1, @(-0.1)];
    NSMutableArray<UIMenuElement *> *rotationActions = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [items enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil
                                          handler:^(__kindof UIAction *action) {
            [weakSelf rotateImage:angles[index].doubleValue];
        }];
        [rotationActions addObject:action];
    }];
    segmentedItem.menuRepresentation = [UIMenu menuWithTitle:ROTATE children:rotationActions];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil
                             action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(adjustImageDone)];

    self.rotateImageMenuItems = @[segmentedItem, flexibleSpace, doneItem];
}


- (void)rotateSegmentChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self rotateImageRight:nil];
            break;
        case 1:
            [self rotateImageLeft:nil];
            break;
        case 2:
            [self tweakImageRight:nil];
            break;
        case 3:
            [self tweakImageLeft:nil];
            break;
        case 4:
            [self microTweakImageRight:nil];
            break;
        case 5:
            [self microTweakImageLeft:nil];
            break;
        default:
            break;
    }
    sender.selectedSegmentIndex = UISegmentedControlNoSegment; // deselect after action
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
    self.qtcMeasureRateButton = [[UIBarButtonItem alloc] initWithTitle:MEASURE_RR style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureRR)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];

    NSArray *array = [NSArray arrayWithObjects:self.qtcMeasureRateButton, cancelButton, nil];
    self.qtcStep1MenuItems = [self spaceoutToolbar:array];
}

- (void)createQTcStep2Toolbar {
    self.qtcMeasureQTcButton = [[UIBarButtonItem alloc] initWithTitle:MEASURE_QT style:UIBarButtonItemStylePlain target:self action:@selector(qtcMeasureQT)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectMainToolbar)];

    NSArray *array = [NSArray arrayWithObjects:self.qtcMeasureQTcButton,
                      cancelButton, nil];
    self.qtcStep2MenuItems = [self spaceoutToolbar:array];
}

- (void)createMovementToolbar {
    NSArray *items = @[LEFT_ARROW, UP_ARROW, RIGHT_ARROW, DOWN_ARROW,
                       MICRO_LEFT_ARROW, MICRO_UP_ARROW, MICRO_RIGHT_ARROW, MICRO_DOWN_ARROW];

    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
    control.momentary = YES;
    [control addTarget:self action:@selector(movementSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.movementSegmentedControl = control;

    // The wrapper is resized to leave room for Done on modern toolbars.
    UIView *controlWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    control.frame = controlWrapper.bounds;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [controlWrapper addSubview:control];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:controlWrapper];
    if (@available(iOS 26.0, *)) {
        segmentedItem.hidesSharedBackground = YES;
    }
    if (@available(iOS 27.0, *)) {
        segmentedItem.paddingRemoved = YES;
    }

    // Supply the segment actions if a narrow layout requires the overflow menu.
    NSMutableArray<UIMenuElement *> *movementActions = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [items enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil
                                          handler:^(__kindof UIAction *action) {
            [weakSelf moveForSegmentIndex:index];
        }];
        [movementActions addObject:action];
    }];
    segmentedItem.menuRepresentation = [UIMenu menuWithTitle:TWEAK children:movementActions];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil
                             action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(doneTweaking)];

    self.movementMenuItems = @[segmentedItem, flexibleSpace, doneButton];
}

- (void)movementSegmentChanged:(UISegmentedControl *)sender {
    [self moveForSegmentIndex:sender.selectedSegmentIndex];
    sender.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (void)moveForSegmentIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self moveLeft];
            break;
        case 1:
            [self moveUp];
            break;
        case 2:
            [self moveRight];
            break;
        case 3:
            [self moveDown];
            break;
        case 4:
            [self microMoveLeft];
            break;
        case 5:
            [self microMoveUp];
            break;
        case 6:
            [self microMoveRight];
            break;
        case 7:
            [self microMoveDown];
            break;
        default:
            break;
    }
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
        [self showToolbarItems:self.qtcStep1MenuItems];
        self.inRRForQTc = YES;
    }
}

- (void)qtcMeasureRR {
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
                [self showToolbarItems:self.qtcStep2MenuItems];
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
            [self showToolbarItems:self.qtcStep2MenuItems];
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
    [self resetCalibration];
    [self.calipersView setNeedsDisplay];
}


- (void)setupCalibration {
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
        [self selectMainToolbar];
        return;
    }
    if (self.calipersView.calipers.count < 1) {
        [self showNoCalipersAlert];
    }
    else {
        [self showToolbarItems:self.calibrateMenuItems];
        [self.calipersView selectCaliperIfNoneSelected];
    }
}

- (void)setCalibration {
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

// The main actions live outside UIToolbar so the system cannot overflow them.
- (void)createMainActionBar {
    if (@available(iOS 26.0, *)) {
        self.mainActionBar = [[UIView alloc] initWithFrame:CGRectZero];
        self.mainActionBar.hidden = YES;
        self.mainActionBar.accessibilityIdentifier = @"mainActionBar";
        [self.view addSubview:self.mainActionBar];

        NSArray<UIBarButtonItem *> *items = @[self.calibrateCalipersButton,
            self.toggleIntervalRateButton, self.mRRButton, self.qtcButton];
        NSArray<NSString *> *identifiers = @[@"calibrateAction", @"intervalRateAction",
            @"meanRateAction", @"qtcAction"];
        NSArray<NSString *> *labels = @[L(@"Calibration_ht"), L(@"Interval_rate_ht"),
            L(@"Mean_rate_ht"), L(@"QTc_ht")];
        NSMutableArray<UIButton *> *buttons = [[NSMutableArray alloc] init];
        for (NSUInteger index = 0; index < items.count; index++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.configuration = [UIButtonConfiguration glassButtonConfiguration];
            button.accessibilityIdentifier = identifiers[index];
            button.accessibilityLabel = labels[index];
            [button addTarget:self action:items[index].action forControlEvents:UIControlEventTouchUpInside];
            [self.mainActionBar addSubview:button];
            [buttons addObject:button];
        }
        self.mainActionButtons = buttons;
        self.mainActionBar.accessibilityElements = buttons;
        [self updateMainActionButtons];
    }
}

- (void)updateMainActionButtons {
    if (self.mainActionButtons.count == 0) {
        return;
    }
    NSArray<UIBarButtonItem *> *items = @[self.calibrateCalipersButton,
        self.toggleIntervalRateButton, self.mRRButton, self.qtcButton];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody
                     compatibleWithTraitCollection:self.traitCollection];
    for (NSUInteger index = 0; index < items.count; index++) {
        UIButton *button = self.mainActionButtons[index];
        UIButtonConfiguration *configuration = button.configuration;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        configuration.attributedTitle = [[NSAttributedString alloc]
            initWithString:items[index].title
            attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle}];
        configuration.titleAlignment = UIButtonConfigurationTitleAlignmentCenter;
        // Character wrapping also accommodates long, unbroken translated labels.
        configuration.titleLineBreakMode = NSLineBreakByCharWrapping;
        configuration.contentInsets = NSDirectionalEdgeInsetsMake(10, 12, 10, 12);
        button.configuration = configuration;
        button.titleLabel.adjustsFontSizeToFitWidth = NO;
        button.enabled = items[index].enabled;
    }
    [self.view setNeedsLayout];
}

- (void)showToolbarItems:(NSArray<UIBarButtonItem *> *)items {
    if (@available(iOS 26.0, *)) {
        self.mainActionBarSelected = (items == self.mainMenuItems);
        self.toolbarItems = self.mainActionBarSelected ? @[] : items;
        [self setBottomControlsHidden:self.bottomControlsHidden animated:NO];
    } else {
        self.toolbarItems = items;
    }
}

- (void)setBottomControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    self.bottomControlsHidden = hidden;
    if (@available(iOS 26.0, *)) {
        self.mainActionBar.hidden = hidden || !self.mainActionBarSelected;
        [self.navigationController setToolbarHidden:(hidden || self.mainActionBarSelected)
                                           animated:animated];
        [self layoutMainActionBar];
    } else {
        [self.navigationController setToolbarHidden:hidden animated:animated];
    }
}

- (void)layoutMainActionBar {
    if (self.mainActionBar == nil) {
        return;
    }

    CGFloat reservedHeight = 0;
    if (!self.mainActionBar.hidden) {
        const CGFloat margin = 16;
        const CGFloat spacing = 8;
        UIEdgeInsets safeInsets = self.view.safeAreaInsets;
        CGFloat width = CGRectGetWidth(self.view.bounds) - safeInsets.left - safeInsets.right - 2 * margin;
        if (width <= 0) {
            return;
        }

        CGFloat naturalWidths[4];
        CGFloat requiredWidth = 3 * spacing;
        for (NSUInteger index = 0; index < self.mainActionButtons.count; index++) {
            UIButton *button = self.mainActionButtons[index];
            // Measure the configured text directly: UIButton may defer applying a new
            // configuration until its next update, returning stale sizes in the meantime.
            NSDirectionalEdgeInsets padding = button.configuration.contentInsets;
            naturalWidths[index] = MAX(44, ceil(button.configuration.attributedTitle.size.width)
                + padding.leading + padding.trailing);
            requiredWidth += naturalWidths[index];
        }
        BOOL twoRows = requiredWidth > width;
        NSUInteger columns = twoRows ? 2 : 4;
        CGFloat rowHeights[2] = {44, 44};
        CGFloat buttonWidths[4];
        for (NSUInteger index = 0; index < self.mainActionButtons.count; index++) {
            CGFloat buttonWidth = twoRows ? (width - spacing) / 2
                : naturalWidths[index] + (width - requiredWidth) / 4;
            buttonWidths[index] = buttonWidth;
            UIButtonConfiguration *configuration = self.mainActionButtons[index].configuration;
            NSDirectionalEdgeInsets padding = configuration.contentInsets;
            CGFloat textWidth = MAX(1, buttonWidth - padding.leading - padding.trailing);
            CGRect textBounds = [configuration.attributedTitle boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            NSUInteger row = index / columns;
            rowHeights[row] = MAX(rowHeights[row], ceil(CGRectGetHeight(textBounds)) + padding.top + padding.bottom);
        }
        CGFloat height = rowHeights[0] + (twoRows ? spacing + rowHeights[1] : 0);
        // Remove only our own safe-area contribution to avoid a layout feedback loop.
        CGFloat bottomInset = MAX(0, safeInsets.bottom - self.mainActionBarInset);
        self.mainActionBar.frame = CGRectMake(safeInsets.left + margin,
            CGRectGetMaxY(self.view.bounds) - bottomInset - spacing - height, width, height);

        CGFloat x = 0;
        for (NSUInteger index = 0; index < self.mainActionButtons.count; index++) {
            NSUInteger row = index / columns;
            if (index % columns == 0) {
                x = 0;
            }
            CGFloat y = row == 0 ? 0 : rowHeights[0] + spacing;
            self.mainActionButtons[index].frame = CGRectMake(x, y, buttonWidths[index], rowHeights[row]);
            x += buttonWidths[index] + spacing;
        }
        [self.view bringSubviewToFront:self.mainActionBar];
        reservedHeight = height + 2 * spacing;
    }

    // The storyboard anchors both ECG and calipers to the safe area.
    if (fabs(reservedHeight - self.mainActionBarInset) > 0.5) {
        UIEdgeInsets insets = self.additionalSafeAreaInsets;
        insets.bottom += reservedHeight - self.mainActionBarInset;
        self.mainActionBarInset = reservedHeight;
        self.additionalSafeAreaInsets = insets;
    }
}

// Select toolbars
- (void)selectPDFToolbar {
    [self showToolbarItems:self.pdfMenuItems];
}

- (void)doneTweaking {
    self.tweakingInProgress = NO;
    [self.calipersView clearAllChosenComponents];
    [self.calipersView setNeedsDisplay];
    if (self.inQtc) {
        [self showToolbarItems:self.qtcStep2MenuItems];
    }
    else if (self.inRRForQTc) {
        [self showToolbarItems:self.qtcStep1MenuItems];
    }
    else {
        [self selectMainToolbar];
    }
}

- (void)selectMainToolbar {
    [self showToolbarItems:self.mainMenuItems];
    [self.calipersView setUserInteractionEnabled:YES];
    BOOL enable = [self.horizontalCalibration canDisplayRate];
    [self.toggleIntervalRateButton setEnabled:enable];
    [self.mRRButton setEnabled:enable];
    [self.qtcButton setEnabled:enable];
    [self updateMainActionButtons];
    self.calipersView.allowTweakPosition = NO;
    self.inQtc = NO;
    self.inRRForQTc = NO;
    self.chosenCaliper = nil;
    self.chosenCaliperComponent = None;
    [self.calipersView clearAllChosenComponents];
    [self.calipersView setNeedsDisplay];
}

- (void)selectRotateImageToolbar {
    [self updateRotateToolbarLayout];
    [self showToolbarItems:self.rotateImageMenuItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateRotateToolbarLayout];
    [self updateMovementToolbarLayout];
    [self layoutMainActionBar];
}

- (void)updateRotateToolbarLayout {
    if (@available(iOS 26.0, *)) {
        UIToolbar *toolbar = self.navigationController.toolbar;
        CGFloat availableWidth = CGRectGetWidth(toolbar.bounds)
            - toolbar.safeAreaInsets.left - toolbar.safeAreaInsets.right;
        if (availableWidth <= 0 || self.rotateImageMenuItems.count == 0) {
            return;
        }

        // Reserve space for Done, outer margins, and the gap between toolbar items.
        // Below 264 points, keep usable segment widths and allow the menu fallback.
        CGFloat width = MAX(264.0, MIN(320.0, availableWidth - 112.0));
        UIBarButtonItem *segmentedItem = self.rotateImageMenuItems.firstObject;
        UIView *wrapper = segmentedItem.customView;
        if (fabs(CGRectGetWidth(wrapper.frame) - width) > 0.5) {
            CGRect frame = wrapper.frame;
            frame.size.width = width;
            wrapper.frame = frame;
            segmentedItem.width = width;
        }
    }
}

- (void)updateMovementToolbarLayout {
    if (@available(iOS 26.0, *)) {
        UIToolbar *toolbar = self.navigationController.toolbar;
        CGFloat availableWidth = CGRectGetWidth(toolbar.bounds)
            - toolbar.safeAreaInsets.left - toolbar.safeAreaInsets.right;
        if (availableWidth <= 0 || self.movementMenuItems.count == 0) {
            return;
        }

        // Reserve space for Done, outer margins, and the gap between toolbar items.
        // Below 264 points, keep usable segment widths and allow the menu fallback.
        CGFloat width = MAX(264.0, MIN(320.0, availableWidth - 112.0));
        UIBarButtonItem *segmentedItem = self.movementMenuItems.firstObject;
        UIView *wrapper = segmentedItem.customView;
        if (fabs(CGRectGetWidth(wrapper.frame) - width) > 0.5) {
            CGRect frame = wrapper.frame;
            frame.size.width = width;
            wrapper.frame = frame;
            segmentedItem.width = width;
        }
    }
}

- (void)selectCalibrateToolbar {
    [self showToolbarItems:self.calibrateMenuItems];
}

- (void)selectColorToolbar {
    [self showToolbarItems:self.colorMenuItems];
}

- (void)selectMovementToolbar {
    [self updateMovementToolbarLayout];
    [self showToolbarItems:self.movementMenuItems];
}

// FIXME: This is broken in iOS 26 beta.  It opens the Settings app, but not the specific EP Calipers page.
// Need to retest this on later versions of iOS 26 because it is probably a bug that Apple may or may not fix.
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
- (void)updateMenusForSizeClass {
    // Menu font changes take effect when the menu is changed.
    [self fixupMenus:[self isCompactSizeClass]];

    [self.toggleIntervalRateButton setTitle:[self selectSize:TOGGLE_INT_RATE_IPAD compactSize:TOGGLE_INT_RATE_IPHONE]];
    [self.mRRButton setTitle:[self selectSize:MEAN_RATE_IPAD compactSize:MEAN_RATE_IPHONE]];
    [self.calibrateCalipersButton setTitle:[self selectSize:CALIBRATE_IPAD compactSize:CALIBRATE_IPHONE]];
    [self updateMainActionButtons];
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

- (void)chooseColor:(Caliper *)caliper {
    UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
    self.chosenCaliper = caliper;
    picker.selectedColor = caliper.unselectedColor;
    picker.delegate = self;
    picker.supportsAlpha = YES;

    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    picker.presentationController.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)tweakComponent:(CaliperComponent)component forCaliper:(Caliper *)caliper {
    EPSLog(@"tweakComponent called");
    self.tweakingInProgress = YES;
    self.chosenCaliper = caliper;
    self.chosenCaliperComponent = component;
    caliper.chosenComponent = component;
    [self.calipersView clearChosenComponentsExceptFor:caliper];

    BOOL disableUpDown = caliper.direction == Horizontal && component != Crossbar;
    BOOL disableLeftRight = caliper.direction == Vertical && component != Crossbar;

    // Segment indexes (adjust if you reorder items)
    NSInteger upIndex = 1;
    NSInteger downIndex = 3;
    NSInteger microUpIndex = 5;
    NSInteger microDownIndex = 7;
    NSInteger leftIndex = 0;
    NSInteger rightIndex = 2;
    NSInteger microLeftIndex = 4;
    NSInteger microRightIndex = 6;

    [self.movementSegmentedControl setEnabled:!disableUpDown forSegmentAtIndex:upIndex];
    [self.movementSegmentedControl setEnabled:!disableUpDown forSegmentAtIndex:microUpIndex];
    [self.movementSegmentedControl setEnabled:!disableUpDown forSegmentAtIndex:downIndex];
    [self.movementSegmentedControl setEnabled:!disableUpDown forSegmentAtIndex:microDownIndex];

    [self.movementSegmentedControl setEnabled:!disableLeftRight forSegmentAtIndex:leftIndex];
    [self.movementSegmentedControl setEnabled:!disableLeftRight forSegmentAtIndex:microLeftIndex];
    [self.movementSegmentedControl setEnabled:!disableLeftRight forSegmentAtIndex:rightIndex];
    [self.movementSegmentedControl setEnabled:!disableLeftRight forSegmentAtIndex:microRightIndex];

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

#pragma mark - ColorPickerViewControllerDelegate Methods

- (void)colorPickerViewController:(UIColorPickerViewController *)viewController
                  didSelectColor:(UIColor *)color
                    continuously:(BOOL)continuously {
    EPSLog(@"colorPickerViewController didSelectColor");
    if (self.chosenCaliper != nil) {
        self.chosenCaliper.color = color;
        self.chosenCaliper.unselectedColor = color;
        self.chosenCaliper.selected = NO;
        [self.calipersView setNeedsDisplay];
    }
}

#pragma mark - restore view controller state

// see https://useyourloaf.com/blog/state-preservation-and-restoration/
- (void)encodeSceneStateWithCoder:(NSCoder *)coder
{
    EPSLog(@"encodeSceneStateWithCoder");
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

}

- (void)restoreSceneStateWithCoder:(NSCoder *)coder
{
    EPSLog(@"restoreSceneStateWithCoder");
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

#pragma mark - UIContextMenuInteractionDelegate

- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                          configurationForMenuAtLocation:(CGPoint)location {

    if (@available(iOS 26.0, *)) {
        if (self.hamburgerMenuIsOpen) {
            return nil;
        }

        // CALIPERS VIEW
        if (interaction.view == self.calipersView) {
            EPSLog(@"Long press calipers view from main");
            self.pressLocation = location;

            if (self.tweakingInProgress) {
                [self tweakAction];
                return nil;
            }

            return [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                           previewProvider:nil
                                                            actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {

                NSMutableArray<UIMenuElement *> *actions = [NSMutableArray array];

                UIAction *colorAction = [UIAction actionWithTitle:COLOR
                                                            image:nil
                                                       identifier:nil
                                                          handler:^(__kindof UIAction * _Nonnull action) {
                    [self colorAction];
                }];
                [actions addObject:colorAction];

                UIAction *tweakAction = [UIAction actionWithTitle:TWEAK
                                                            image:nil
                                                       identifier:nil
                                                          handler:^(__kindof UIAction * _Nonnull action) {
                    [self tweakAction];
                }];
                [actions addObject:tweakAction];

                if ([self.calipersView caliperNearLocationIsTimeCaliper:location]) {
                    BOOL result = [self.calipersView caliperIsMarching:location];

                    UIAction *marchAction = [UIAction actionWithTitle:MARCH
                                                                image:nil
                                                           identifier:nil
                                                              handler:^(__kindof UIAction * _Nonnull action) {
                        [self marchAction];
                    }];
                    // Set checkmark if marching
                    marchAction.state = result ? UIMenuElementStateOn : UIMenuElementStateOff;

                    [actions addObject:marchAction];
                }

                UIAction *deleteAction = [UIAction actionWithTitle:DELETE
                                                             image:nil
                                                        identifier:nil
                                                           handler:^(__kindof UIAction * _Nonnull action) {
                    [self deleteAction];
                }];
                deleteAction.attributes = UIMenuElementAttributesDestructive;
                [actions addObject:deleteAction];

                UIAction *doneAction = [UIAction actionWithTitle:DONE
                                                           image:nil
                                                      identifier:nil
                                                         handler:^(__kindof UIAction * _Nonnull action) {
                    [self doneMenuAction];
                }];
                [actions addObject:doneAction];

                return [UIMenu menuWithTitle:@"" children:actions];
            }];
        }

        // SCROLL VIEW
        if (interaction.view == self.scrollView) {
            EPSLog(@"Long press scroll view from main");

            BOOL isMultipagePDF = self.numberOfPages > 1 && pdfRef != NULL;

            return [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                           previewProvider:nil
                                                            actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {

                NSMutableArray<UIMenuElement *> *actions = [NSMutableArray array];

                UIAction *rotateAction = [UIAction actionWithTitle:ROTATE
                                                             image:nil
                                                        identifier:nil
                                                           handler:^(__kindof UIAction * _Nonnull action) {
                    [self rotateAction];
                }];
                [actions addObject:rotateAction];

                UIAction *flipAction = [UIAction actionWithTitle:FLIP
                                                           image:nil
                                                      identifier:nil
                                                         handler:^(__kindof UIAction * _Nonnull action) {
                    [self flipAction];
                }];
                [actions addObject:flipAction];

                UIAction *resetAction = [UIAction actionWithTitle:RESET
                                                            image:nil
                                                       identifier:nil
                                                          handler:^(__kindof UIAction * _Nonnull action) {
                    [self resetAction];
                }];
                [actions addObject:resetAction];

                if (isMultipagePDF || SHOW_PDF_MENU) {
                    UIAction *pdfAction = [UIAction actionWithTitle:PDF
                                                              image:nil
                                                         identifier:nil
                                                            handler:^(__kindof UIAction * _Nonnull action) {
                        [self pdfAction];
                    }];
                    [actions addObject:pdfAction];
                }

                UIAction *doneAction = [UIAction actionWithTitle:DONE
                                                           image:nil
                                                      identifier:nil
                                                         handler:^(__kindof UIAction * _Nonnull action) {
                    [self doneMenuAction];
                }];
                [actions addObject:doneAction];

                return [UIMenu menuWithTitle:@"" children:actions];
            }];
        }
    }

    return nil; // fallback if triggered by something unexpected or if IOS version < 26
}

#pragma -- long press
- (void)doCalipersViewLongPress:(UILongPressGestureRecognizer *)sender {
    EPSLog(@"long press calipers view from main");
    if (sender.state != UIGestureRecognizerStateBegan || self.hamburgerMenuIsOpen) {
        return;
    }
    [sender.view becomeFirstResponder];
    CGPoint location = [sender locationInView:self.calipersView];
    self.pressLocation = location;
    if (self.tweakingInProgress) {
        [self tweakAction];
        return;
    }
    UIEditMenuConfiguration *configuration =
        [UIEditMenuConfiguration configurationWithIdentifier:nil sourcePoint:location];
    [self.calipersEditMenuInteraction presentEditMenuWithConfiguration:configuration];
}

- (void)doScrollViewLongPress:(UILongPressGestureRecognizer *)sender {
    EPSLog(@"Long press from main");
    if (sender.state != UIGestureRecognizerStateBegan || self.hamburgerMenuIsOpen) {
        return;
    }
    [sender.view becomeFirstResponder];
    // The source point uses the interaction's view coordinates, including its bounds origin.
    CGPoint location = [sender locationInView:self.scrollView];
    UIEditMenuConfiguration *configuration =
        [UIEditMenuConfiguration configurationWithIdentifier:nil sourcePoint:location];
    [self.scrollEditMenuInteraction presentEditMenuWithConfiguration:configuration];
}

#pragma mark - UIEditMenuInteractionDelegate

- (UIMenu *)editMenuInteraction:(UIEditMenuInteraction *)interaction
          menuForConfiguration:(UIEditMenuConfiguration *)configuration
              suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions {
    NSMutableArray<UIMenuElement *> *actions = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    if (interaction == self.calipersEditMenuInteraction) {
        [actions addObject:[UIAction actionWithTitle:COLOR image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf colorAction];
        }]];
        [actions addObject:[UIAction actionWithTitle:TWEAK image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf tweakAction];
        }]];
        if ([self.calipersView caliperNearLocationIsTimeCaliper:configuration.sourcePoint]) {
            [actions addObject:[UIAction actionWithTitle:MARCH image:nil identifier:nil
                                               handler:^(__kindof UIAction *action) {
                [weakSelf marchAction];
            }]];
        }
        [actions addObject:[UIAction actionWithTitle:DELETE image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf deleteAction];
        }]];
    } else if (interaction == self.scrollEditMenuInteraction) {
        [actions addObject:[UIAction actionWithTitle:ROTATE image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf rotateAction];
        }]];
        [actions addObject:[UIAction actionWithTitle:FLIP image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf flipAction];
        }]];
        [actions addObject:[UIAction actionWithTitle:RESET image:nil identifier:nil
                                           handler:^(__kindof UIAction *action) {
            [weakSelf resetAction];
        }]];
        BOOL isMultipagePDF = self.numberOfPages > 1 && pdfRef != NULL;
        if (isMultipagePDF || SHOW_PDF_MENU) {
            [actions addObject:[UIAction actionWithTitle:PDF image:nil identifier:nil
                                               handler:^(__kindof UIAction *action) {
                [weakSelf pdfAction];
            }]];
        }
    } else {
        return [UIMenu menuWithTitle:@"" children:@[]];
    }

    [actions addObject:[UIAction actionWithTitle:DONE image:nil identifier:nil
                                       handler:^(__kindof UIAction *action) {
        [weakSelf.calipersEditMenuInteraction dismissMenu];
        [weakSelf.scrollEditMenuInteraction dismissMenu];
        [weakSelf doneMenuAction];
    }]];
    return [UIMenu menuWithTitle:@"" children:actions];
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    // No need to do anything with dismissal.
}

@end
