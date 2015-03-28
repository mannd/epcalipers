//
//  Settings.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.caliperColor = [UIColor blackColor];
        self.highlightColor = [UIColor redColor];
        self.lineWidth = 2; // should = 1
    }
    return self;
}

@end
