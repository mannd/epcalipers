//
//  HelpObject.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpTopic.h"

@implementation HelpTopic
- (instancetype)initWithTopic:(NSString *)topic text:(NSString *)text {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.text = text;
    }
    return self;
}

@end
