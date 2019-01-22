//
//  HelpViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/31/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpImageViewController.h"
#import "WebViewController.h"
#import "HelpProtocol.h"
#import "Translation.h"
#import "Defs.h"
#import "EPSLogging.h"

#define VIEW_CONTROLLERS_COUNT 4

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"HelpViewController did load.");
    // Do any additional setup after loading the view.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"helpPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.images = @[@"move-caliper", @"tap-caliper", @"zoom-ecg", @"longpress"];
    self.titles = @[L(@"Move_caliper_label"), L(@"Tap_caliper_label"), L(@"Zoom_ecg_label"), L(@"Longpress_label")];
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self didMoveToParentViewController:self];

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];

    [self.navigationController setNavigationBarHidden:YES];
    self.title = @"";
}

#pragma mark - Page view controller data source

- (UIViewController <HelpProtocol>*)viewControllerAtIndex:(NSUInteger)index {
    if (index >= VIEW_CONTROLLERS_COUNT) {
        return nil;
    }
    HelpImageViewController *helpImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"helpImageViewController"];
    helpImageViewController.imageName = self.images[index];
    helpImageViewController.labelText = self.titles[index];
    if (index == VIEW_CONTROLLERS_COUNT - 1) {
        helpImageViewController.skipButtonText = L(@"Done");
    }
    else {
        helpImageViewController.skipButtonText = L(@"Skip");
    }
    helpImageViewController.pageIndex = index;
    return helpImageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((UIViewController<HelpProtocol> *)viewController).pageIndex;
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((UIViewController<HelpProtocol> *)viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == VIEW_CONTROLLERS_COUNT) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return VIEW_CONTROLLERS_COUNT;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)quitHelp {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
