//
//  ManualLink.m
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "ManualLink.h"

@implementation ManualLink
- (instancetype)initWithChapter:(NSString *)chapter anchor:(NSString *)anchor {
    self = [super init];
    if (self) {
        self.chapter = chapter;
        self.anchor = anchor;
    }
    return self;
}

@end
