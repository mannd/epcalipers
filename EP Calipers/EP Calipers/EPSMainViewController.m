//
//  ViewController.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "EPSMainViewController.h"
#import "Caliper.h"
#import "Settings.h"
#import "EPSLogging.h"


@interface EPSMainViewController ()

@end

@implementation EPSMainViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0)];
//    [navigationBar setDelegate:self];
//    [self.view addSubview:navigationBar];
//    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"EP Calipers"];
//    [navigationBar pushNavigationItem:titleItem animated:NO];
    self.settings = [[Settings alloc] init];
    
    [self createMainToolbar];
    [self createImageToolbar];
    [self createAdjustImageToolbar];
    [self createAddCalipersToolbar];
    
    [self selectMainToolbar];
 
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 4.0;
    [self.scrollView setZoomScale:1.0];
    
    self.horizontalCalibration = [[Calibration alloc] init];
    self.horizontalCalibration.direction = Horizontal;
    self.verticalCalibration = [[Calibration alloc] init];
    self.verticalCalibration.direction = Vertical;
    
    [self.calipersView setUserInteractionEnabled:YES];
     
    // add a Caliper to start out
    [self addHorizontalCaliper];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.calipersView setUserInteractionEnabled:YES];
    
}

-(UIBarPosition)positionForBar:(id <UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createMainToolbar {
    UIBarButtonItem *addCaliperButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectAddCalipersToolbar)];
    UIBarButtonItem *calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:@"Calibrate" style:UIBarButtonItemStylePlain target:self action:@selector(calibrateCalipers:)];
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithTitle:@"Image" style:UIBarButtonItemStylePlain target:self action:@selector(selectImageToolbar:)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.mainMenuItems = [NSArray arrayWithObjects:addCaliperButton, calibrateCalipersButton, imageButton, settingsButton, helpButton, nil];


}

- (void)createImageToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto:)];
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
    UIBarButtonItem *backToImageMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(selectImageToolbar:)];
    
    self.adjustImageMenuItems = [NSArray arrayWithObjects:rotateImageRightButton, rotateImageLeftButton, tweakRightButton, tweakLeftButton, flipImageButton, resetImageButton, backToImageMenuButton, nil];
    
}

- (void)createAddCalipersToolbar {
    UIBarButtonItem *horizontalButton = [[UIBarButtonItem alloc] initWithTitle:@"Horizontal" style:UIBarButtonItemStylePlain target:self action:@selector(addHorizontalCaliper)];
    UIBarButtonItem *verticalButton = [[UIBarButtonItem alloc] initWithTitle:@"Vertical" style:UIBarButtonItemStylePlain target:self action:@selector(addVerticalCaliper)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(selectMainToolbar)];
    
    self.addCalipersMenuItems = [NSArray arrayWithObjects:horizontalButton, verticalButton, backToMainMenuButton, nil];

}

- (IBAction)selectImageToolbar:(id)sender {
    [self.toolbar setItems:self.photoMenuItems];
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)selectMainToolbar {
    [self.toolbar setItems:self.mainMenuItems];
    [self.calipersView setUserInteractionEnabled:YES];
}

- (void)selectAddCalipersToolbar {
    [self.toolbar setItems:self.addCalipersMenuItems];
}

- (IBAction)selectAdjustImageToolbar {
    [self.toolbar setItems:self.adjustImageMenuItems];
}

- (IBAction)calibrateCalipers:(id)sender {
    // substitute text for buttons
    // "Measure known time interval with calipers, press button when ready to calibrate"
}

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(id)sender {
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
    [caliper setInitialPositionInRect:self.view.frame];
    
    [self.calipersView.calipers addObject:caliper];
    [self.calipersView setNeedsDisplay];
   
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

- (IBAction)tweakLeft:(id)sender {
    [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];
    
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(-1));
    
    [UIView commitAnimations];
}

- (void)rotateImage:(double)degrees {
    [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];
    
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(degrees));
    
    [UIView commitAnimations];

}

- (IBAction)resetImage:(id)sender {
    [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];
    
    self.imageView.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
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
    [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];

    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, x, y);
    
    [UIView commitAnimations];
}

@end
