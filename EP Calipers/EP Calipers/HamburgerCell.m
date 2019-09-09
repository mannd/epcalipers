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
    // Initialization code
    // FIXME: Need to make final decision on hamberger icon colors
    // Note: Uncommenting below will make icons white
//    if (@available(iOS 11.0, *)) {
//        self.icon.tintColor = [UIColor colorNamed:@"customIconColor"];
//    } else {
//        // Fallback on earlier versions
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
