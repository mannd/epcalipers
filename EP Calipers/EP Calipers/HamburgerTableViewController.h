//
//  HamburgerTableViewController.h
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HamburgerTableViewController : UITableViewController
@property (strong, nonatomic) NSArray* rows;
@property (nonatomic) BOOL imageIsLocked;
@property (nonatomic) BOOL showingToolTips;
- (void)nextPage;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
