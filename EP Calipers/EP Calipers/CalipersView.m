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
        UIPanGestureRecognizer *draggingPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        [self addGestureRecognizer:draggingPanGestureRecognizer];
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecognizer];
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        self.clearsContextBeforeDrawing = YES;
        self.locked = NO;
   }
    return self;
}


//TESTEST!!!!!!!!!
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:point]) {
            return YES;
        }
    }
    return NO;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef con = UIGraphicsGetCurrentContext();
    for (Caliper *caliper in self.calipers) {
        [caliper drawWithContext:con inRect:rect];
    }
}

- (void)selectCaliperNoNeedsDisplay:(Caliper *)c {
    c.color = c.selectedColor;
    c.selected = YES;
}

- (void)unselectCaliperNoNeedsDisplay:(Caliper *)c {
    c.color = c.unselectedColor;
    c.selected = NO;
}

- (void)selectCaliper:(Caliper *)c {
    [self selectCaliperNoNeedsDisplay:c];
    [self setNeedsDisplay];
}

- (void)unselectCaliper:(Caliper *)c {
    [self unselectCaliperNoNeedsDisplay:c];
    [self setNeedsDisplay];
}

// Single tap initially highlights (selects) caliper,
// second tap unselects it.  Quick double tap is used
// to delete caliper.  This is new behavior with v2.0+.
- (void)singleTap:(UITapGestureRecognizer *)t {
    if (self.locked) {
        return;
    }
    CGPoint location = [t locationInView:self];
    BOOL caliperToggled = NO;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location] && !caliperToggled) {
            caliperToggled = YES;
            if (((Caliper *)self.calipers[i]).selected) {
                [self unselectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
            }
            else  {
                [self selectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
            }
        }
        else {
            [self unselectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
        }
    }
    if (caliperToggled) {
        [self setNeedsDisplay];
    }
}

// method not used at present
- (Caliper *)getSelectedCaliper:(CGPoint) point {
    Caliper *foundCaliper = nil;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:point] && foundCaliper == nil) {
            foundCaliper = (Caliper *)self.calipers[i];
        }
    }
    return foundCaliper;
}

- (void)doubleTap:(UITapGestureRecognizer *)t {
    if (self.locked) {
        return;
    }
    CGPoint location = [t locationInView:self];
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
            [self.calipers removeObject:self.calipers[i]];
            [self setNeedsDisplay];
            return;
        }
    }
}



- (void)dragging:(UIPanGestureRecognizer *)p {
    CGPoint location = [p locationInView:self];
    static Caliper *selectedCaliper = nil;
    static BOOL bar1Selected = NO;
    static BOOL bar2Selected = NO;
    static BOOL crossBarSelected = NO;
    BOOL selectionMade = NO;
    if (p.state == UIGestureRecognizerStateBegan) {
        for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
            if ([(Caliper *)self.calipers[i] pointNearCaliper:location]  && !selectionMade) {
                selectedCaliper = (Caliper *)self.calipers[i];
                if ([selectedCaliper pointNearCrossBar:location]) {
                    crossBarSelected = YES;
                    selectionMade = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar1Position]) {
                    bar1Selected = YES;
                    selectionMade = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar2Position]) {
                    bar2Selected = YES;
                    selectionMade = YES;
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

@end
