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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTap:)];
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

// The other gestures (UIPanGestureRecognizer and UIScreenEdgePanGestureRecognizer) don't
// work in that they interfere with the panning of the UIImageView in the UIScrollView.
// I tried various solutions, but none satisfactory.  So unfortunately we end up with a
// non-swipable hamburger menu.  However UIScrollView doesn't have a tap gesture, so we
// can use that to close the menu.
- (void)gestureTap:(id)sender {
    EPSLog(@"gesture tap");
    if (self.delegate != nil && self.delegate.hamburgerMenuIsOpen) {
        [self.delegate hideHamburgerMenu];
    }
}

@end
