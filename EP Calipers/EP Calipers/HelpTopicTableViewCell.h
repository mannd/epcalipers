//
//  HelpTopicTableViewCell.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HelpTopicTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *helpTopicLabel;
@property (strong, nonatomic) IBOutlet UILabel *helpTextLabel;
- (void)set:(HelpViewModel *)content;
@end

NS_ASSUME_NONNULL_END
