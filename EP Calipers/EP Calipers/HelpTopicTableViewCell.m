//
//  HelpTopicTableViewCell.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpTopicTableViewCell.h"

@implementation HelpTopicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)set:(HelpViewModel *)content {
    self.helpTopicLabel.text = content.topic;
    self.helpTextLabel.text = content.expanded ? content.text : @"";
}
@end

