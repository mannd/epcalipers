//
//  CaliperView.m
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "CalipersView.h"
#import "EPSLogging.h"
#import "EPSMainViewController.h"

@implementation CalipersView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.calipers = array;
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:t];
        UIPanGestureRecognizer *p = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        [self addGestureRecognizer:p];
        self.clearsContextBeforeDrawing = YES;
        self.toolbar = ((EPSMainViewController *)self.superview).toolbar;
        self.locked = NO;
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(deviceOrientationDidChangeNotification:)
         name:UIDeviceOrientationDidChangeNotification
         object:nil];
   }
    return self;
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note {
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef con = UIGraphicsGetCurrentContext();
    for (Caliper *caliper in self.calipers) {
        [caliper drawWithContext:con inRect:rect];
    }
}

- (void)selectCaliper:(Caliper *)c {
    c.color = c.selectedColor;
    c.selected = YES;
    [self setNeedsDisplay];    
}

- (void)unselectCaliper:(Caliper *)c {
    c.color = c.unselectedColor;
    c.selected = NO;
    [self setNeedsDisplay];
}

// Single tap initially highlites caliper, second tap deletes it.  Thus,
// deletion can be down with a quick double tap or more methodically, or cancelled by
// unselecting the caliper.
- (void)singleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
    BOOL selectionMade = NO;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location] && !selectionMade) {
            if (((Caliper *)self.calipers[i]).selected && !self.locked ) {
                [self.calipers removeObject:self.calipers[i]];
                [self setNeedsDisplay];
                return;
            }
            else  {
                [self selectCaliper:(Caliper *)self.calipers[i]];
                selectionMade = YES;
            }
        }
        else {
            [self unselectCaliper:(Caliper *)self.calipers[i]];
        }
    }
}

- (void)dragging:(UIPanGestureRecognizer *)p {
    CGPoint location = [p locationInView:self];
    static Caliper *selectedCaliper = nil;
    static BOOL bar1Selected = NO;
    static BOOL bar2Selected = NO;
    static BOOL crossBarSelected = NO;
    if (p.state == UIGestureRecognizerStateBegan) {
        for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
            if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
                selectedCaliper = (Caliper *)self.calipers[i];
                if ([selectedCaliper pointNearCrossBar:location]) {
                    crossBarSelected = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar1Position]) {
                    bar1Selected = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar2Position]) {
                    bar2Selected = YES;
                }
            }
        }
    }
    if (p.state == UIGestureRecognizerStateEnded) {
        selectedCaliper = nil;
        bar1Selected = NO;
        bar2Selected = NO;
        crossBarSelected = NO;
        return;
    }
    if (selectedCaliper != nil) {
        CGPoint delta = [p translationInView:self];
        // swap delta x and y for vertical
        if (selectedCaliper.direction == Vertical) {
            float tmp = delta.x;
            delta.x = delta.y;
            delta.y = tmp;
        }
        if (crossBarSelected) {
            selectedCaliper.bar1Position += delta.x;
            selectedCaliper.bar2Position += delta.x;
            selectedCaliper.crossBarPosition += delta.y;
        }
        else if (bar1Selected) {
            selectedCaliper.bar1Position += delta.x;
        }
        else if (bar2Selected) {
            selectedCaliper.bar2Position += delta.x;
        }
        [p setTranslation:CGPointZero inView:self];
        [self setNeedsDisplay];
    }
}

- (void)selectCaliperIfNoneSelected {
    if (self.calipers.count > 0 && [self noCaliperIsSelected]) {
        [self selectCaliper:(Caliper *)self.calipers[self.calipers.count - 1]];
    }
}

- (BOOL)noCaliperIsSelected {
    BOOL noneSelected = YES;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] selected]) {
            noneSelected = NO;
        }
    }
    return noneSelected;
}

- (Caliper *)activeCaliper {
    if (self.calipers.count <= 0) {
        return nil;
    }
    Caliper *c = nil;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] selected]) {
            c = (Caliper *)self.calipers[i];
        }
    }
    return c;
}

// Keeps calipers measuring same interval (though can move around with rotation).
// Vertical calipers tend to go to screen edges.
- (void)shiftCalipers:(double)ratio forNewHeight:(double)height {
    for (Caliper *c in self.calipers) {
        if (c != nil) {
            double compensation = 1 / ratio;
            c.bar1Position *= compensation;
            c.bar2Position *= compensation;
            if (c.direction == Vertical) {
                [self moveCaliperTowardsCenter:c forCenter:(double)height/2.0];
            }
        }
    }
}

- (void)moveCaliperTowardsCenter:(Caliper *)caliper forCenter:(double)center {
    // caliper straddles middle, leave it be
    if (caliper.bar1Position < center && caliper.bar2Position > center) {
        return;
    }
    if (caliper.bar1Position > center) {
        double delta = caliper.bar1Position - center;
        caliper.bar1Position -= delta;
        caliper.bar2Position -= delta;
    } else if (caliper.bar2Position < center) {
        double delta = center - caliper.bar2Position;
        caliper.bar1Position += delta;
        caliper.bar2Position += delta;
    }
}


@end
