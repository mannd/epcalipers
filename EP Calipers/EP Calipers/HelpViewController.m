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

#define VIEW_CONTROLLERS_COUNT 3

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
    self.images = @[L(@"Help_image_1"), L(@"Help_image_2"), L(@"Help_image_3")];
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

    self.title = L(@"Quick_help");
}

#pragma mark - Page view controller data source

- (UIViewController <HelpProtocol>*)viewControllerAtIndex:(NSUInteger)index {
    if (index >= VIEW_CONTROLLERS_COUNT) {
        return nil;
    }
    HelpImageViewController *helpImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"helpImageViewController"];
    helpImageViewController.imageName = self.images[index];
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

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    NSUInteger index = ((UIViewController<HelpProtocol> *)self.pageViewController.viewControllers[0]).pageIndex;
    if (index == VIEW_CONTROLLERS_COUNT - 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitHelp)];
    }
}

- (void)quitHelp {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
