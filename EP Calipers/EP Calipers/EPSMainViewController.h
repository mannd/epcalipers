//
//  ViewController.h
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPSMainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *calipersView;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property NSArray *mainMenuItems;
@property NSArray *photoMenuItems;
@property NSArray *calipersMenuItems;

@end

