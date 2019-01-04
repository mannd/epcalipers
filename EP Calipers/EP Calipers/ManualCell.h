//
//  ManualTableViewCell.h
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManualLink.h"

NS_ASSUME_NONNULL_BEGIN

@interface ManualCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *topicLabel;
- (void)set:(ManualLink *)manualLink;

@end

NS_ASSUME_NONNULL_END
