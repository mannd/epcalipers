//
//  EcgImageView.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "EcgImageView.h"
#import "EPSLogging.h"

@implementation EcgImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.allowSideSwipe = NO;
        UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
        screenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
        screenEdgePanGestureRecognizer.enabled = YES;
        [self addGestureRecognizer:screenEdgePanGestureRecognizer];
        self.userInteractionEnabled = self.allowSideSwipe;
    }
    return self;
}

- (void)screenEdgePan:(id)sender {
    EPSLog(@"screen edge pan");
}


@end
