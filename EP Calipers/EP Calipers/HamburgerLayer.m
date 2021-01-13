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
        self.icon = [UIImage imageNamed:iconName];
        self.layer = layer;
        self.altIcon = nil;
        self.altName = nil;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName layer:(Layer)layer altName:(NSString *)altName altIconName:(NSString *)altIconName {
    self = [super init];
    if (self) {
        self.name = name;
        self.icon = [UIImage imageNamed:iconName];
        self.layer = layer;
        self.altIcon = [UIImage imageNamed:altIconName];
        self.altName = altName;
    }
    return self;
}

@end

