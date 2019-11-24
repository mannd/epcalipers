//
//  HamburgerCell.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HamburgerCell.h"

@implementation HamburgerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.icon.tintColor = [UIColor systemBlueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
