//
//  ManualLink.m
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "ManualLink.h"

@implementation ManualLink

// ManualLink can be either a full link or just an anchor.
- (instancetype)initWithChapter:(NSString *)chapter anchor:(NSString *)anchor {
    self = [super init];
    if (self) {
        self.chapter = chapter;
        self.anchor = anchor;
        self.fullLink = nil;
    }
    return self;
}

- (instancetype)initWithChapter:(NSString *)chapter link:(NSString *)link {
    self = [super init];
    if (self) {
        self.chapter = chapter;
        self.anchor = nil;
        self.fullLink = link;
    }
    return self;
}
@end
