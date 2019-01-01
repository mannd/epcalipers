//
//  HelpTableViewController.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HelpTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, HelpProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *helpArray;
@property (nonatomic) NSUInteger pageIndex;
@end

NS_ASSUME_NONNULL_END
