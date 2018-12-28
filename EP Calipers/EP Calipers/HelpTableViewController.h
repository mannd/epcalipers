//
//  HelpTableViewController.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *helpArray;
@end

NS_ASSUME_NONNULL_END
