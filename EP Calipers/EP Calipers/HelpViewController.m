//
//  HelpViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/31/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpViewController.h"
#include "Defs.h"

#define VIEW_CONTROLLERS_COUNT 2

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"helpPageViewController"];
    self.pageViewController.dataSource = self;
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self didMoveToParentViewController:self];
    self.index = 0;

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Page view controller data source

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0: return [self.storyboard instantiateViewControllerWithIdentifier:@"helpImageViewController"];
        case 1: return [self.storyboard instantiateViewControllerWithIdentifier:@"helpTableViewController"];
        default: return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.index == 0 || self.index == NSNotFound) {
        return nil;
    }
    self.index--;
    return [self viewControllerAtIndex:self.index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.index == NSNotFound) {
        return nil;
    }
    self.index++;
    if (self.index == VIEW_CONTROLLERS_COUNT) {
        return nil;
    }
    return [self viewControllerAtIndex:self.index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return VIEW_CONTROLLERS_COUNT;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
