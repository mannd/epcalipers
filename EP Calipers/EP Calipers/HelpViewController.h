//
//  HelpViewController.h
//  EP Calipers
//
//  Created by David Mann on 12/31/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSArray *images;
@property (nonatomic) BOOL firstStart;
@end

NS_ASSUME_NONNULL_END
