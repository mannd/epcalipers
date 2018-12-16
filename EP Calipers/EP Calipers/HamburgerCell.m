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
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0.9607843137 green:(CGFloat)0.9647058824 blue:0.9725490196 alpha:1];
    self.selectedBackgroundView = bgColorView;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
