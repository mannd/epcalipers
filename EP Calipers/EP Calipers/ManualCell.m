//
//  ManualTableViewCell.m
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "ManualCell.h"

@implementation ManualCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)set:(ManualLink *)manualLink {
    self.topicLabel.text = manualLink.chapter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
