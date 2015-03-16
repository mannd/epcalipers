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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // if no camera on device, just silently disable take photo button
        [self.takePhotoButton setEnabled:NO];
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.75;
    self.scrollView.maximumZoomScale = 1.2;
    self.scrollView.zoomScale = 1.0;
    [self.scrollView setClipsToBounds:YES];
    [self.scrollView setBouncesZoom:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
   // self.scrollView.contentSize = self.imageView.image.size;
    NSLog(@"imageView.size.height = %f", self.imageView.image.size.height);
    NSLog(@"imageView.size.width = %f", self.imageView.image.size.width);
    NSLog(@"scrollView.content.height = %f", self.scrollView.contentSize.height);
    NSLog(@"scrollView.content.width = %f", self.scrollView.contentSize.width);

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
