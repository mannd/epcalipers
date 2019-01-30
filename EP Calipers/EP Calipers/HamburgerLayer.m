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
        self.altName = nil;
        self.altIconName = nil;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName layer:(Layer)layer altName:(NSString *)altName altIconName:(NSString *)altIconName {
    self = [super init];
    if (self) {
        self.name = name;
        self.iconName = iconName;
        self.layer = layer;
        self.altName = altName;
        self.altIconName = altIconName;
    }
    return self;
}

@end

