//
//  HamburgerLayer.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HamburgerLayer.h"

@implementation HamburgerLayer

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName layer:(Layer)layer {
    self = [super init];
    if (self) {
        self.name = name;
        self.iconName = iconName;
        self.layer = layer;
    }
    return self;
}

@end

