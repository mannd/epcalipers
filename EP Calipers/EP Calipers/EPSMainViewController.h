//
//  EPSMainViewController.h
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalipersView.h"
#import "BlackView.h"
#import "Calibration.h"
#import "Settings.h"
#import "FCColorPickerViewController.h"
#import "HamburgerTableViewController.h"
#import <CMPopTipView/CMPopTipView.h>
#import <PencilKit/PencilKit.h>

@protocol QTcResultProtocol
- (NSString *)calculateFromQtInSec: (double)qtInSec rrInSec: (double)rrInSec formula: (QTcFormulaPreference)formula convertToMsec: (BOOL)convertToMsec units:(NSString *)units;
@end

@interface EPSMainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIContextMenuInteractionDelegate, FCColorPickerViewControllerDelegate, CalipersViewDelegate, HamburgerDelegate, CMPopTipViewDelegate, UIDocumentPickerDelegate, PKCanvasViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet CalipersView *calipersView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHamburgerLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHamburgerWidth;
@property (weak, nonatomic) IBOutlet BlackView *blackView;
@property (nonatomic) CGFloat maxBlackAlpha;

// We get this view via its embed segue!  See prepareForSegue:
@property (strong, nonatomic) HamburgerTableViewController *hamburgerViewController;

@property (strong, nonatomic) UIBarButtonItem *toggleIntervalRateButton;
@property (strong, nonatomic) UIBarButtonItem *mRRButton;
@property (strong, nonatomic) UIBarButtonItem *qtcButton;
@property (strong, nonatomic) UIBarButtonItem *calibrateCalipersButton;
@property (strong, nonatomic) UIBarButtonItem *setButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;
@property (strong, nonatomic) UIBarButtonItem *qtcMeasureRateButton;
@property (strong, nonatomic) UIBarButtonItem *qtcMeasureQTcButton;
@property (strong, nonatomic) UIBarButtonItem *previousPageButton;
@property (strong, nonatomic) UIBarButtonItem *nextPageButton;
//@property (strong, nonatomic) UIBarButtonItem *brugadaButton;
@property (strong, nonatomic) UIBarButtonItem *leftButton;
@property (strong, nonatomic) UIBarButtonItem *rightButton;
@property (strong, nonatomic) UIBarButtonItem *upButton;
@property (strong, nonatomic) UIBarButtonItem *downButton;
@property (strong, nonatomic) UIBarButtonItem *microLeftButton;
@property (strong, nonatomic) UIBarButtonItem *microRightButton;
@property (strong, nonatomic) UIBarButtonItem *microUpButton;
@property (strong, nonatomic) UIBarButtonItem *microDownButton;
@property (strong, nonatomic) UIBarButtonItem *lockImageButton;


@property (strong, nonatomic) NSArray *mainMenuItems;
@property (strong, nonatomic) NSArray *pdfMenuItems;
//@property (strong, nonatomic) NSArray *photoMenuItems;
@property (strong, nonatomic) NSArray *calipersMenuItems;
@property (strong, nonatomic) NSArray *rotateImageMenuItems;
@property (strong, nonatomic) NSArray *addCalipersMenuItems;
@property (strong, nonatomic) NSArray *calibrateMenuItems;
@property (strong, nonatomic) NSArray *qtcStep1MenuItems;
@property (strong, nonatomic) NSArray *qtcStep2MenuItems;
@property (strong, nonatomic) NSArray *moreMenuItems;
@property (strong, nonatomic) NSArray *colorMenuItems;
@property (strong, nonatomic) NSArray *tweakMenuItems;
@property (strong, nonatomic) NSArray *movementMenuItems;

@property (strong, nonatomic) Calibration *horizontalCalibration;
@property (strong, nonatomic) Calibration *verticalCalibration;
@property (strong, nonatomic) Settings *settings;

@property (nonatomic) double rrIntervalForQTc;
@property (nonatomic) BOOL firstRun;
@property (nonatomic) BOOL firstStart;
@property (nonatomic) BOOL launchFromURL;
@property (strong, nonatomic) NSURL *launchURL;
@property (nonatomic) BOOL hamburgerMenuIsOpen;

@property (nonatomic) BOOL isCalipersView;

@property (nonatomic) CGFloat sizeDiffWidth;
@property (nonatomic) CGFloat sizeDiffHeight;

@property (nonatomic) BOOL isRotatedImage;

@property (nonatomic) CGFloat portraitWidth;
@property (nonatomic) CGFloat portraitHeight;
@property (nonatomic) CGFloat landscapeWidth;
@property (nonatomic) CGFloat landscapeHeight;

- (void)openURL:(NSURL *)url;
- (void)hideHamburgerMenu;
- (void)showHamburgerMenu;  
- (void)takePhoto;
- (void)selectImage;
- (void)selectImageSource;
- (void)snapshotScreen;
- (void)showHelp;
- (void)showManual;
- (void)loadDefaultImage;
- (void)showAbout;
- (void)openSettings;
- (void)lockImage;
- (BOOL)imageIsLocked;
- (void)showToolTips;
- (BOOL)isIpad;

@property (nonatomic) BOOL tweakingInProgress;
@property (nonatomic) BOOL showingToolTips;

//@property (nonatomic) CGPDFDocumentRef documentRef;
@property (nonatomic) int pageNumber;
@property (nonatomic) int numberOfPages;

@property (nonatomic) BOOL defaultHorizontalCalChanged;
@property (nonatomic) BOOL defaultVerticalCalChanged;

- (void)chooseColor:(Caliper *)caliper;
@property (nonatomic, weak) Caliper *chosenCaliper;
@property (nonatomic) CaliperComponent chosenCaliperComponent;

@property (nonatomic) BOOL wasLaunchedFromUrl;
@property (nonatomic) BOOL inRRForQTc;
@property (nonatomic) BOOL inQtc;

// New installation, upgrade?
@property (nonatomic) BOOL isNewInstallation;
@property (nonatomic) BOOL isUpgrade;
@property (strong, nonatomic) NSString* priorMajorVersion;
@property (strong, nonatomic) NSString* priorVersion;
@property (strong, nonatomic) NSString* currentVersion;

@property (strong, nonatomic) PKCanvasView *canvasView;
@property (strong, nonatomic) PKToolPicker *toolPicker;

@end

