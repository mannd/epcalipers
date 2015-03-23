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
    
    // pass touches through
    [self.calipersView setUserInteractionEnabled:NO];
    
//    // add view for calipers
//    UIView *caliperView = [[UIView alloc] initWithFrame:self.imageView.frame];
// //   [self.view addSubview:caliperView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createMainToolbar {
    UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithTitle:@"Photo" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhotoToolbar)];
    UIBarButtonItem *calipersButton = [[UIBarButtonItem alloc] initWithTitle:@"Calipers" style:UIBarButtonItemStylePlain target:self action:@selector(selectCalipersToolbar)];

    
    self.mainMenuItems = [NSArray arrayWithObjects:photoButton, calipersButton, nil];
}

- (void)createPhotoToolbar {
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto:)];
    UIBarButtonItem *selectPhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto:)];
    UIBarButtonItem *rotatePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Rotate" style:UIBarButtonItemStylePlain target:self action:@selector(rotatePhoto:)];
    UIBarButtonItem *backToMainMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(selectMainToolbar)];
    
    self.photoMenuItems = [NSArray arrayWithObjects:takePhotoButton, selectPhotoButton, rotatePhotoButton, backToMainMenuButton, nil];
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
    //
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
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)rotatePhoto:(id)sender {

   [UIView beginAnimations:nil context:nil]; [UIView setAnimationDuration:1.0f]; [UIView setAnimationDelegate:self];
//
   self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, radians(90));
//
//
    
  //self.imageView.image = [self rotateImage:self.imageView.image onDegrees:90];
 //   self.imageView.image = rotate(self.imageView.image, UIImageOrientationLeft);
    
   [UIView commitAnimations];
}

- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees
{
    CGFloat rads = M_PI * degrees / 180;
    float newSide = MAX([image size].width, [image size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextRotateCTM(ctx, rads);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[image size].width/2,-[image size].height/2,size.width, size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}
@end
