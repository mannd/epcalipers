//
//  ViewController.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "EPSMainViewController.h"

@interface EPSMainViewController ()

@end

@implementation EPSMainViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createMainToolbar];
    [self createPhotoToolbar];
    [self createCalipersToolbar];
    
    [self selectMainToolbar];
 
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    [self.scrollView setZoomScale:1.0];
    
    // pass touches through calipers view to image initially
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createMainToolbar {
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithTitle:@"Image" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhotoToolbar)];
    UIBarButtonItem *calipersButton = [[UIBarButtonItem alloc] initWithTitle:@"Calipers" style:UIBarButtonItemStylePlain target:self action:@selector(selectCalipersToolbar)];
    
    self.mainMenuItems = [NSArray arrayWithObjects:imageButton, calipersButton, nil];
}

- (void)createPhotoToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto:)];
    UIBarButtonItem *selectImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto:)];
    UIBarButtonItem *rotateImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Rotate" style:UIBarButtonItemStylePlain target:self action:@selector(rotateImage:)];
    UIBarButtonItem *tweakLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweak L" style:UIBarButtonItemStylePlain target:self action:@selector(tweakLeft:)];
    UIBarButtonItem *flipImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStylePlain target:self action:@selector(flipImage:)];
    UIBarButtonItem *resetImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetImage:)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(selectMainToolbar)];
    
    self.photoMenuItems = [NSArray arrayWithObjects:takePhotoButton, selectImageButton, rotateImageButton, tweakLeftButton, flipImageButton, resetImageButton, backToMainMenuButton, nil];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // if no camera on device, just silently disable take photo button
        [takePhotoButton setEnabled:NO];
    }
}

- (void)createCalipersToolbar {
    UIBarButtonItem *calibrateCalipersButton = [[UIBarButtonItem alloc] initWithTitle:@"Calibrate" style:UIBarButtonItemStylePlain target:self action:@selector(calibrateCalipers:)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(selectMainToolbar)];
    
    self.calipersMenuItems = [NSArray arrayWithObjects:calibrateCalipersButton, backToMainMenuButton, nil];
}

- (void)selectPhotoToolbar {
    [self.toolBar setItems:self.photoMenuItems];
}

- (void)selectMainToolbar {
    [self.toolBar setItems:self.mainMenuItems];
    [self.calipersView setUserInteractionEnabled:NO];
}

- (void)selectCalipersToolbar {
    [self.toolBar setItems:self.calipersMenuItems];
    [self.calipersView setUserInteractionEnabled:YES];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
 
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
//{
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint touchLocation = [touch locationInView:touch.view];
//    self.imageView.center = touchLocation;
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // get touch event
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint touchLocation = [touch locationInView:self.imageView];
//    
//    if ([touch view] == self.view)
//    {
//        
//        self.imageView.center = touchLocation;
//        
//        
//    }
//}

static inline double radians (double degrees) {return degrees * M_PI/180;}

- (IBAction)rotateImage:(id)sender {

   [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];

   self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(90));
    
   [UIView commitAnimations];
}

- (IBAction)tweakLeft:(id)sender {
    [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];
    
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(-1));
    
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
