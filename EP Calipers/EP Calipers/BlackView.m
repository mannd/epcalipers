//
//  BlackView.m
//  EP Calipers
//
//  Created by David Mann on 1/13/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "BlackView.h"

@implementation BlackView

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
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTap:)];
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePan:)];
        panGestureRecognizer.enabled = YES;
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        self.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

- (void)gesturePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat translationX = [sender translationInView:sender.view].x;
        if (translationX > 0) {
            self.delegate.constraintHamburgerLeft.constant = 0;
            self.alpha = self.delegate.maxBlackAlpha;
        }
        else if (translationX < -(self.delegate.constraintHamburgerWidth.constant)) {
            self.alpha = 0;
        }
        else {
            self.delegate.constraintHamburgerLeft.constant = translationX;
            CGFloat ratio = (self.delegate.constraintHamburgerWidth.constant + translationX) / self.delegate.constraintHamburgerWidth.constant;
            double alphaValue = ratio * self.delegate.maxBlackAlpha;
            self.alpha = alphaValue;
        }
    }
    else {
        if (self.delegate.constraintHamburgerLeft.constant < -self.delegate.constraintHamburgerWidth.constant / 2) {
            [self.delegate hideHamburgerMenu];
        }
        else {
            [self.delegate showHamburgerMenu];
        }
    }
}

- (void)gestureTap:(id)sender {
    if (self.delegate != nil && self.delegate.hamburgerMenuIsOpen) {
        [self.delegate hideHamburgerMenu];
    }
}


@end
