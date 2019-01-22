//
//  HelpImageViewController.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HelpImageViewController : UIViewController <HelpProtocol>
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIImageView *helpImageView;
@property (strong, nonatomic) NSString *imageName;
@property (nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSString *labelText;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) NSString *skipButtonText;
- (IBAction)skipAction:(id)sender;
@end

NS_ASSUME_NONNULL_END
